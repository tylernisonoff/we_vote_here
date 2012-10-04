class Election < ActiveRecord::Base
  require 'set'
  
  attr_accessible :name, :info, :choices_attributes, :group_id, :votes_attributes, :start_time, :finish_time
  
  has_many :votes, dependent: :destroy
  has_many :valid_svcs, dependent: :destroy
  
  has_many :preferences, dependent: :destroy
  has_many :choices, dependent: :destroy

  belongs_to :group

  accepts_nested_attributes_for :valid_svcs, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }
  accepts_nested_attributes_for :choices, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }

  validates_presence_of :group

  validates :name, presence: true, length: { within: 2..255 }

  # validates :choices, length: { minimum: 2, message: "^Election must have at least 2 choices" }
  validate :choices_check

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :start_time, presence: true
  validates :finish_time, presence: true

  validate :check_start_time, on: :create
  validate :check_finish_time, on: :create

  # with probability 1/2, returns a random number between min and max
  # with probability 1/2, returns a random number between -min and -max
  
  def check_start_time
    errors.add(:start_time, "^Group cannot start before now.") unless self.start_time + 30.minutes >= Time.now
  end

  def check_finish_time
    if self.start_time == self.finish_time
      errors.add(:finish_time, "^Group cannot end when it begins.")
    elsif self.start_time > self.finish_time
      errors.add(:finish_time, "^Group cannot end before it begins.")
    else
      true
    end
  end

  def new_random (min, max)
    return (rand * (max-min) + min)
  end

  def trash_election
    self.trashed = true
    if self.save
      self.valid_svcs.each do |valid_svc|
        valid_svc.trash_valid_svc
      end
    end
  end


  def complete(winner_hash)
    n = self.choices.size
    num_comparisons = 0
    winner_hash.each do |choice_id, defeated|
        num_comparisons = num_comparisons + defeated.size()
    end

    if num_comparisons == ((n-1)*n)/2
      return true
    else
      return false
    end
  end

  def create_tie_breaking_vote
    choice_ids = choice_id_array(false)
    n = choice_ids.size
    sum_of_choice_ids = 0
    choice_ids.each do |id|
      sum_of_choice_ids += id
    end


    # tie breaking votes have SVCs equal to the election_id
    unless Vote.exists?(svc: self.id.to_s)
      tie_breaking_vote = Vote.new
      tie_breaking_vote.election_id = self.id
      tie_breaking_vote.svc = self.id.to_s
      tie_breaking_vote.tie_breaking = true
      tie_breaking_vote.save
    else
      tie_breaking_vote = Vote.find(:first, conditions: {svc: self.id.to_s})
      Preference.delete_all(svc: tie_breaking_vote.svc)
    end
    # stores pos: set of ids, and is complete when there are:
    # n positions, each with sets of exactly one element.
    # Here, we initialize it.
    tie_breaking_hash = Hash.new
    (1..n).each do |pos|
      tie_breaking_hash[pos] = Set.new
    end

    # keep track of union of values of tie_breaking_hash
    added_to_hash = Set.new
    active_votes = Vote.find(:all, conditions: {election_id: self.id, active: true})
    randomly_chosen = false
    until complete_tbv(tie_breaking_hash) || randomly_chosen

      # in the case that we couldn't resolve this via picking votes,
      # we make a random vote with fully filled out preferences.
      if active_votes.size == 0
        unless Vote.exists?(svc: (-1*self.id).to_s)
          random_vote = Vote.new
          random_vote.election_id = self.id
          random_vote.svc = (-1*self.id).to_s # random votes have the svc of -1*election_id
          random_vote.tie_breaking = true
          random_vote.save
        else
          random_vote = Vote.find(:first, conditions: {svc: (-1*self.id).to_s})
          Preference.delete_all(svc: random_vote.svc)
        end
        random_prefs = Hash.new
        (1..n).each do |pos|
          c = choice_ids.sample
          choice_ids.delete(c)
          random_prefs[pos] = c
        end
        random_prefs.each do |pos, c_id|
          pref = Preference.new
          pref.tie_breaking = true
          pref.svc = random_vote.svc
          pref.vote_id = random_vote.id
          pref.position = pos
          pref.choice_id = c_id
          pref.save
        end
        active_votes.push(random_vote)
        randomly_chosen = true
      end
      # picks a vote (deterministically but very neutrally) and deletes it
      # from list of votes to consider in the future
      v = active_votes.delete_at(sum_of_choice_ids % active_votes.size)
      save_v = Vote.new
      save_v.election_id = v.election_id
      save_v.svc = (-1*(v.svc.to_i)).to_s
      save_v.tie_breaking = true
      save_v.save

      resolve_tbv_conflicts(tie_breaking_hash, v.svc)

      preferences = Preference.find(:all, conditions: {svc: v.svc, active: true})
      new_prefs = Hash.new
      # populate new prefs
      preferences.each do |pref|
        unless new_prefs[pref.position]
          new_prefs[pref.position] = Set.new
        end
        new_prefs[pref.position].add(pref.choice_id)
      end

      # make sure both of these are sorted by pos, 
      # as it is critical for the algo to work
      tie_breaking_hash.sort_by { |k,v| k }
      new_prefs.sort_by { |k,v| k }

      # fills out tie_breaking_hash as much as the vote 'v' can
      
      new_prefs.each do |v_pos, v_set|
        temp = added_to_hash.size + 1
        v_set.each do |v_choice|
          unless added_to_hash.include?(v_choice)
            tie_breaking_hash[temp].add(v_choice)
            added_to_hash.add(v_choice)
          end
        end
      end
    end
    tie_breaking_hash.each do |pos, s|
      pref = Preference.new
      pref.tie_breaking = true
      pref.svc = tie_breaking_vote.svc
      pref.vote_id = tie_breaking_vote.id
      pref.position = pos
      pref.choice_id = s.to_a[0]
      pref.save
    end
  end

  def resolve_tbv_conflicts(tie_breaking_hash, svc)
    # stores map from pos --> id as expressed by the vote with svc: svc
    # note that this function assumes that (for example) a pending-tie 
    # for first place between 2 people means that the choice that is next  
    # on the ballot ill be in 3rd place, NOT second place.
    tie_breaking_hash.each do |pos, set|
      if set.size > 1
        temp = Hash.new
        set.each do |choice_id|
          new_pos = Preference.find(:first, conditions: {svc: svc, active: true, choice_id: choice_id}).position
          unless temp[new_pos]
            temp[new_pos] = Set.new
          end
          temp[new_pos].add(choice_id) 
        end
        # sort by new_pos's in ascending order
        temp.sort_by { |k,v| k }
        
        # move sets of choice_ids to different pos in tie_breaking_hash
        i = 0
        temp.each do |new_pos, subset|
          tie_breaking_hash[pos + i] = subset
          i = i + 1
        end
      end
    end
  end

  def complete_tbv(tie_breaking_hash)
    n = self.choices.size
    test_set = Set.new
    tie_breaking_hash.each do |pos, set|
      if pos <= n && pos >= 1
        test_set.add(pos)
      else
        return false
      end
      unless set.size == 1
        return false
      end
    end
    if test_set.size == n
      return true
    else
      return false
    end
  end

  def choice_name_array(sort_by_results = false)
    @sorted_choices = get_sorted_choices(sort_by_results)

    @choice_names = Array.new
    @sorted_choices.each do |choice|
      @choice_names.push(choice.name)
    end
    return @choice_names
  end

  def get_choice_hash
    choice_hash = Hash.new
    choices = Choice.find(:all, conditions: {election_id: self.id, trashed: false})
    choices.each do |choice|
      choice_hash[choice.id] = choice.name
    end

    return choice_hash
  end

  def choice_id_array(sort_by_results = false)
    # If sort_by_results is true, returns choice ids sorted by choice id
    @sorted_choices = get_sorted_choices(sort_by_results)

    # If sort_by_results is false or blank, returns choice ids sorted by choice id
    @choice_ids = Array.new
    @sorted_choices.each do |choice|
      @choice_ids.push(choice.id)
    end
    return @choice_ids
  end

  def get_sorted_choices(sort_by_results = false)

    # in the future, modify this to check the DB
    # for times when we have already ran ranked pairs
    # so we don't call it again

    if sort_by_results
    # If true, returns array of choices sorted by ranked pairs results
      @results_hash = ranked_pairs(false, true)
      @sorted_choices = self.choices.sort_by { |a| @results_hash[a.id] }
    else
    # If false or empty, returns array of choices sorted by choice id
      @sorted_choices = self.choices.sort_by { |a| a.id }
    end

    return @sorted_choices
  end

# This should be recoded.
  def choices_check
  	self.choices.each do |choice1|
  		count = 0
  		self.choices.each do |choice2|
  			if choice1.name == choice2.name
  				count = count + 1
  			end
  		end
  		if count > 1
  			errors.add(:choices, "^Names of choices must be unique.")
  			break
  		end
  	end
  	return true
  end

  def get_voter_array
    voter_array = Array.new
    self.group.voters.each_with_index do |voter, index|
      voter_array[index] = Array.new
      voter.valid_emails.each do |valid_email|
        voter_array[index].push(valid_email.email)
      end
    end
    return voter_array
  end

  def send_election_emails(voter_array=false)
    unless voter_array
      # populate voter_array if there's no argument
      voter_array = get_voter_array
    end

    if self.group.privacy
      voter_array.each do |voters_email|
        @valid_svc = ValidSvc.new
        @valid_svc.election = self
        @valid_svc.assign_valid_svc
        if @valid_svc.save
          voters_email.each do |email|
            UserMailer.election_email(email, self, @valid_svc.svc).deliver
          end
        end
      end
    else
      voter_array.each do |voters_emails|
        voters_emails.each do |email|
          UserMailer.election_email(email, self).deliver
        end
      end
    end
  end


  def get_active_votes_hash
    # returns hash where keys are vote_id's of active votes and
    # and values are hashes (with keys as choice ids and values as positions

    @votes_hash = Hash.new

    @active_votes = Vote.find(:all, conditions: {election_id: self.id, active: true, trashed: false, tie_breaking: false})
    @active_votes.each do |active_vote|
      @votes_hash[active_vote.id] = Hash.new
      # Using vote.active_preferences does NOT work
      # This has to do with foreign key stuff, watch out.
      @active_preferences = Preference.find(:all, conditions: {svc: active_vote.svc, active: true})
      @active_preferences.each do |active_preference|
        @votes_hash[active_vote.id][active_preference.choice_id] = active_preference.position
      end
    end
    return @votes_hash
  end

  def get_mov(tbv = false) # doesn't work sending data to controller
    
    # Initialize margin-of-victory hash-of-hashes
    # @mov[i][j] stores the margin of victory of choice j over 
    @mov = Hash.new
    @choices = Choice.find(:all, conditions: {election_id: self.id})
    n = @choices.size

    # Initialize MOV as a hash of hashes with all 0 values.
    @choices.each do |choice_1|
      @mov[choice_1.id] = Hash.new
      @choices.each do |choice_2|
        @mov[choice_1.id][choice_2.id] = 0
      end
    end

    @formatted_active_votes = get_active_votes_hash

    @formatted_active_votes.each_value do |vote_hash|
      vote_hash.each do |choice1, position1|
        vote_hash.each do |choice2, position2|
          if choice1 > choice2
            if position1 < position2 # choice 1 is ranked higher (lower number)
              @mov[choice1][choice2] = @mov[choice1][choice2] + 1
              @mov[choice2][choice1] = @mov[choice2][choice1] - 1
            elsif position1 > position2 # choice 2 is ranked higher (lower number)
              @mov[choice2][choice1] = @mov[choice2][choice1] + 1
              @mov[choice1][choice2] = @mov[choice1][choice2] - 1
            end
          end
        end
      end
    end

    if tbv
      tbv_preferences = Preference.find(:all, conditions: {svc: self.id.to_s, tie_breaking: true}) 
      tbv_preferences.each do |pref1|
        pos1 = pref1.position
        tbv_preferences.each do |pref2|
          pos2 = pref2.position
          add = ((pos2-pos1)*(pos1-1).to_f)/((n*n).to_f)
          @mov[pref1.choice_id][pref2.choice_id] += add
          @mov[pref2.choice_id][pref1.choice_id] -= add
        end
      end
    end
    
    return @mov
  end

  def sum_from_1_to_i(i)
    if i == 0
      return 0
    end

    ret = 0
    (1..i.abs).each do |j|
      ret += j
    end
    if i < 0
      return -1*ret
    else
      return ret
    end
  end

  def ranked_pairs(save = false, tbv = true, return_text = false)
    # returns hash where keys are choice_ids and values are positions
    # unless return_text is true, where it returns the ordering

    # Initialize margin-of-victory hash-of-hashes
    # @mov[i][j] stores the margin of victory of choice j over
    if tbv
      # unless Vote.exists?(svc: self.id.to_s)
        create_tie_breaking_vote
      # end
    end

    text = Array.new
    id_to_name_hash = self.get_choice_hash

    @mov = self.get_mov(tbv)
  
    ### ALGO TEST STARTS HERE

    @mov_list = Array.new
    @mov.each do |i, hash|
      hash.each do |j, margin|
        if i > j
          if margin >= 0
            @mov_list.push([margin, i, j])
          else
            @mov_list.push([-1*margin, j, i])
          end
        end
      end
    end

    @mov_list.sort! { |a,b| a[0] <=> b[0] }

    winner_hash = Hash.new
    # for choice id "i",
    # winner_hash[i] stores the set of choices who i defeated

    loser_hash = Hash.new
    # for choice id "i",
    # loser_hash[i] stores the set of choices who defeated i

    until complete(winner_hash)
      if @mov_list.size == 0
        break
      end
      
      # select the next strongest inequality
      strongest_inequality = @mov_list.pop
      
      margin = strongest_inequality[0]
      winner = strongest_inequality[1]
      loser = strongest_inequality[2]

      added = Set.new
      before_merge = Set.new

      [winner, loser].each do |i|
        # If winner_hash[choice] does not exist,
        # create it as an empty set
        [winner_hash, loser_hash].each do |hash|
          unless hash[i]
            hash[i] = Set.new
          end
        end
        # unless winner_hash[i]
        #   winner_hash[i] = Set.new
        # end
        # unless loser_hash[i]
        #   loser_hash[i] = Set.new
        # end
      end

      if winner_hash[loser].include?(winner)
        # if this inequality is inconsistent with
        # previous inequalities, ignore this inequality
        text.push("\nIgnoring: #{id_to_name_hash[winner]} beats #{id_to_name_hash[loser]} by #{margin}\n")
        next
      elsif winner_hash[winner].include?(loser)
        text.push("\nWe already know: #{id_to_name_hash[winner]} beats #{id_to_name_hash[loser]} (by #{margin})\n")
        next
      else
        text.push("\nWinner: #{id_to_name_hash[winner]}\nLoser: #{id_to_name_hash[loser]}\nMargin: #{margin}\n")

        # add the loser to set of those the winner beats
        winner_hash[winner].add(loser)

        # add the winner to the set of those the loser loses to
        loser_hash[loser].add(winner)

        # text.push("#{id_to_name_hash[winner]} beat #{id_to_name_hash[loser]}\n")


        before_merge = Set.new(winner_hash[winner])

        # add the set of choices the loser beat
        # to the set of choices the winner beat
        winner_hash[winner].merge(winner_hash[loser])

        # add the set of choices that beat the winner
        # to the set of choices the loser has lost to.
        loser_hash[loser].merge(loser_hash[winner])

        added = winner_hash[winner] - before_merge
        unless added.empty?
          added.each do |lost_to_loser|
            text.push("#{id_to_name_hash[winner]} beat #{id_to_name_hash[lost_to_loser]}\n")
          end
        end

        # for each choice, "L" that the loser has beaten,
        # add the set of choices that has beaten the loser
        # to the set of choices that has beaten "L"
        winner_hash[loser].each do |lost_to_loser|
          loser_hash[lost_to_loser].merge(loser_hash[loser])
        end

        # for each choice, "W", that beat the winner,
        # add the set of choices that the winner has beaten
        # to the set of choices that W beat.
        loser_hash[winner].each do |beat_winner|
          before_merge = Set.new(winner_hash[beat_winner])
          winner_hash[beat_winner].merge(winner_hash[winner])
          added = winner_hash[beat_winner] - before_merge
          unless added.empty?
            # text.push("Recall: #{winner} lost to #{beat_winner}\n")
            added.each do |lost_to_winner|
              text.push("#{id_to_name_hash[beat_winner]} beat #{id_to_name_hash[lost_to_winner]}\n")
            end
          end
        end
      end
    end

    amount_defeated_hash = Hash.new
    # amount_defeated_hash stores keys: amount_defeated and value: choice_id

    winner_hash.each do |choice, set|
      if choice > 0
        unless amount_defeated_hash[set.size]
          amount_defeated_hash[set.size] = Set.new
        end
        amount_defeated_hash[set.size].add(choice)
      end
    end

    amount_defeated_array = amount_defeated_hash.keys
    # make an array out of keys of amount_defeated_hash

    amount_defeated_array.sort! { |a, b| b <=> a}
    # sort the amount_defeated_array from highest to lowest

    result_hash = Hash.new
    # result_hash stores keys: choice_id and value: final_position

    index = 1
    tie_index = 0
    amount_defeated_array.each do |amount|
      tie_index = 0
      amount_defeated_hash[amount].each do |choice|
        result_hash[choice] = index
        tie_index = tie_index + 1
      end
      index = index + tie_index
    end

    if save
      save_ranked_pairs_results(result_hash)
    end

    if return_text
      return text
    else 
      return result_hash
    end
    
  end

  def save_ranked_pairs_results(result_hash = false)
    if result_hash
      Result.delete_all(election_id: self.id)
      result_hash.each do |choice_id, position|
        @result = Result.new
        @result.election_id = self.id
        @result.position = position
        @result.choice_id = choice_id
        @result.save
      end
    end
  end

  def get_tbv_array
    tbp = Preference.find(:all, conditions: {svc: self.id.to_s, tie_breaking: true})
    ret = Array.new
    tbp.sort_by { |a| a.position }
    tbp.each do |pref|
      ret.push(pref.choice.name)
    end
    return ret
  end

end

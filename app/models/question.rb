class Question < ActiveRecord::Base
  require 'set'
  
  attr_accessible :name, :info, :choices_attributes, :election_id, :votes_attributes # :display_votes_as_created, :finish_time, :privacy, :start_time
  
  has_many :votes, dependent: :destroy
  has_many :valid_svcs, dependent: :destroy
  
  has_many :preferences, dependent: :destroy
  has_many :choices, dependent: :destroy

  belongs_to :election

  accepts_nested_attributes_for :valid_svcs, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }
  accepts_nested_attributes_for :choices, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }

  validates_presence_of :election

  validates :name, presence: true, length: { within: 2..255 }

  # validates :choices, length: { minimum: 2, message: "^Question must have at least 2 choices" }
  validate :choices_check

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # with probability 1/2, returns a random number between min and max
  # with probability 1/2, returns a random number between -min and -max
  def new_random (min, max)
    return (rand * (max-min) + min)
  end


  def complete(winner_hash, n)
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

  def choice_name_array(sort_by_results = false)
    @sorted_choices = get_sorted_choices(sort_by_results)

    @choice_names = Array.new
    @sorted_choices.each do |choice|
      @choice_names.push(choice.name)
    end
    return @choice_names
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
      @results_hash = ranked_pairs
      @sorted_choices = self.choices.sort { |a, b| @results_hash[a.id] <=> @results_hash[b.id] }
    else
    # If false or empty, returns array of choices sorted by choice id
      @sorted_choices = self.choices.sort { |a, b| a.id <=> b.id }
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
    self.election.voters.each_with_index do |voter, index|
      voter_array[index] = Array.new
      voter.valid_emails.each do |valid_email|
        voter_array[index].push(valid_email.email)
      end
    end
    return voter_array
  end


  def create_svcs_for_private(voter_array=false)
    if self.election.privacy
      unless voter_array
        # populate voter_array if there's no argument
        voter_array = get_voter_array
      end
      voter_array.each do |voters_email|
        @valid_svc = ValidSvc.new
        @valid_svc.question = self
        @valid_svc.assign_valid_svc
        if @valid_svc.save
          voters_email.each do |email|
            UserMailer.private_question_email(email, self, @valid_svc.svc).deliver
          end
        else
          flash[:error] = "We were unable to save an SVC. This is not good :("
        end
      end
    end
  end

  def send_emails_for_public(voter_array=false)
    unless self.election.privacy
      unless voter_array
        # populate voter_array if there's no argument
        voter_array = get_voter_array
      end
      voter_array.each do |voters_emails|
        voters_emails.each do |email|
          UserMailer.public_question_email(email, self).deliver
        end
      end
    end
  end


  def get_active_votes_hash
    # returns hash where keys are vote_id's of active votes and
    # and values are hashes (with keys as choice ids and values as positions

    @votes_hash = Hash.new

    @active_votes = ActiveVote.find(:all, conditions: {question_id: self.id})
    @active_votes.each do |active_vote|
      @votes_hash[active_vote.vote_id] = Hash.new
      # Using vote.active_preferences does NOT work
      # This has to do with foreign key stuff, watch out.
      @active_preferences = ActivePreference.find(:all, conditions: {svc: active_vote.svc})
      @active_preferences.each do |active_preference|
        @votes_hash[active_vote.vote_id][active_preference.choice_id] = active_preference.position
      end
    end
    return @votes_hash
  end

  def get_mov # doesn't work sending data to controller
    
    # Initialize margin-of-victory hash-of-hashes
    # @mov[i][j] stores the margin of victory of choice j over 
    @mov = Hash.new
    @choices = Choice.find(:all, conditions: {question_id: self.id})
    
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
  
    return @mov
  end

  def ranked_pairs(save = false)
    # returns hash where keys are choice_ids and values are positions

    # Initialize margin-of-victory hash-of-hashes
    # @mov[i][j] stores the margin of victory of choice j over 
    @mov = self.get_mov
    n = self.choices.size
    printer = 0

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

    until complete(winner_hash, n)
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
        next
      else
        unless printer == 0
          print "\nWinner: #{winner}\nLoser: #{loser}\nMargin: #{margin}\n"
        end

        # add the loser to set of those the winner beats
        winner_hash[winner].add(loser)
        if printer == 1
          print "#{winner} beat #{loser}\n"
        end

        # add the winner to the set of those the loser loses to
        loser_hash[loser].add(winner)
        if printer == -1
          print "#{loser} lost to #{winner}\n"
        end


        # add the set of choices the loser beat
        # to the set of choices the winner beat
        before_merge = Set.new(winner_hash[winner])
        winner_hash[winner].merge(winner_hash[loser])
        
        if printer == 1  
          added = winner_hash[winner] - before_merge
          unless added.empty?
            added.each do |lost_to_loser|
              print "#{winner} beat #{lost_to_loser}\n"
            end
          end
        end

        # add the set of choices that beat the winner
        # to the set of choices the loser has lost to.
        before_merge = Set.new(loser_hash[loser])
        loser_hash[loser].merge(loser_hash[winner])
        
        if printer == -1
          added = loser_hash[loser] - before_merge
          unless added.empty?
            added.each do |beat_winner|
              print "#{loser} lost to #{beat_winner}\n"
            end
          end
        end

        # for each choice, "L" that the loser has beaten,
        # add the set of choices that has beaten the loser
        # to the set of choices that has beaten "L"
        winner_hash[loser].each do |lost_to_loser|
          # print "Recall: #{loser} beat #{lost_to_loser}\n"
          before_merge = Set.new(loser_hash[lost_to_loser])
          loser_hash[lost_to_loser].merge(loser_hash[loser])
          if print == -1
            added = loser_hash[lost_to_loser] - before_merge
            unless added.empty?
              added.each do |beat_loser|
                print "#{lost_to_loser} lost to #{beat_loser}\n"
              end
            end
          end
        end

        # for each choice, "W", that beat the winner,
        # add the set of choices that the winner has beaten
        # to the set of choices that W beat.
        loser_hash[winner].each do |beat_winner|
          # print "Recall: #{winner} lost to #{beat_winner}\n"
          before_merge = Set.new(winner_hash[beat_winner])
          winner_hash[beat_winner].merge(winner_hash[winner])
          if printer == 1
            added = winner_hash[beat_winner] - before_merge
            unless added.empty?
              added.each do |lost_to_winner|
                print "#{beat_winner} beat #{lost_to_winner}\n"
              end
            end
          end
        end

      # print "\n\n"

       # print "\n"
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
    puts "This should print once."
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

    return result_hash
    
  end

  def save_ranked_pairs_results(result_hash = false)
    if result_hash
      Result.delete_all(question_id: self.id)
      result_hash.each do |choice_id, position|
        @result = Result.new
        @result.question_id = self.id
        @result.position = position
        @result.choice_id = choice_id
        @result.save
      end
    end
  end

end

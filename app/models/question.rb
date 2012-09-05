class Question < ActiveRecord::Base
  require 'set'
  
  attr_accessible :name, :info, :choices_attributes, :election_id, :votes_attributes # :display_votes_as_created, :finish_time, :privacy, :start_time
  
  has_many :votes, dependent: :destroy
  has_many :valid_svcs, dependent: :destroy
  
  has_many :preferences, dependent: :destroy
  has_many :choices, dependent: :destroy

  accepts_nested_attributes_for :valid_svcs, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }
  accepts_nested_attributes_for :choices, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }

  belongs_to :election
  # validates_presence_of :election

  validates :name, presence: true, length: { within: 2..255 }

  # validates :choices, length: { minimum: 2, message: "^Question must have at least 2 choices" }
  validate :choices_check

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  def choice_name_array
  # Returns choice names sorted by choice id
    choice_names = Array.new
    @sorted_choices = self.choices.sort { |a, b| a.id <=> b.id }
    @sorted_choices.each do |choice|
      choice_names.push(choice.name)
    end
    return choice_names
  end

  def choice_id_array
    # Returns choice ids sorted by choice id
    choice_array = self.choices
    @choice_ids = Array.new
    choice_array.each do |choice|
      @choice_ids.push(choice.id)
    end
    choice_ids.sort!
    return choice_ids
  end

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

  def create_svcs
    if self.election.privacy
      self.election.voters.each do |voter|
        svc = SecureRandom.urlsafe_base64
        @valid_svc = ValidSvc.new
        @valid_svc.svc = svc
        @valid_svc.question = self
        if @valid_svc.save
          voter.valid_emails.each do |valid_email|
            UserMailer.question_email(valid_email.email, self, svc).deliver
          end
        else
          flash[:error] = "We were unable to save an SVC. This is not good :("
        end
      end
    end
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


    @formatted_votes = Array.new

    @active_votes = ActiveVote.find(:all, conditions: {question_id: self.id})
    # puts "\n\n\n\n\n\nACTIVE VOTES: #{@active_votes} \n\n\n\n\n\n\n"

    @active_votes.each_with_index do |vote, index|
      @formatted_votes[index] = Hash.new
      # Using vote.active_preferences does NOT work
      # This has to do with foreign key stuff, watch out.
      @active_preferences = ActivePreference.find(:all, conditions: {svc: vote.svc})
      @active_preferences.each do |preference|
        @formatted_votes[index][preference.choice_id] = preference.position
      end
    end

    @formatted_votes.each do |vote|
      vote.each do |choice1, position1|
        vote.each do |choice2, position2|
          if choice1 > choice2
            if position1 < position2 # choice 1 is ranked higher (lower number)
              @mov[choice1][choice2] = @mov[choice1][choice2] + 1
              @mov[choice2][choice1] = @mov[choice2][choice1] - 1
            elsif position1 > position2
              @mov[choice2][choice1] = @mov[choice2][choice1] + 1
              @mov[choice1][choice2] = @mov[choice1][choice2] - 1
            end
          end
        end
      end
    end

    # puts "\n\n\n\n\nMODEL: #{@mov} \n\n\n\n\n"
  
    return @mov
  end

  def ranked_pairs

    # Initialize margin-of-victory hash-of-hashes
    # @mov[i][j] stores the margin of victory of choice j over 
    @mov = self.get_mov

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

    result_array = Array.new
    # the winner is the choice who beats the most others

    winner_hash.each do |choice, set|
      if choice > 0
        result_array.push([choice, set.size()])
      end
    end

    # find out who's on top
    result_array.sort! { |a,b| b[1] <=> a[1] }
    

    ### ALGO TEST ENDS HERE


    # insert this into the database
    result_array.each_with_index do |result, index|
      @result = Result.new
      @result.question_id = self.id
      @result.position = index + 1
      @result.choice_id = result[0]
      @result.save
    end
  end

end

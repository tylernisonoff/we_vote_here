class Question < ActiveRecord::Base
  attr_accessible :name, :info, :candidates_attributes, :election_id, :votes_attributes # :display_votes_as_created, :finish_time, :privacy, :start_time
  
  has_many :votes, dependent: :destroy
  has_many :preferences, dependent: :destroy
  has_many :candidates, dependent: :destroy
  accepts_nested_attributes_for :candidates, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }

  belongs_to :election
  # validates_presence_of :election

  validates :name, presence: true, length: { within: 2..255 }

  # validates :candidates, length: { minimum: 2, message: "^Question must have at least 2 candidates" }
  validate :candidates_check

  def candidates_check
  	self.candidates.each do |candidate1|
  		count = 0
  		self.candidates.each do |candidate2|
  			if candidate1.name == candidate2.name
  				count = count + 1
  			end
  		end
  		if count > 1
  			errors.add(:candidates, "^Names of candidates must be unique.")
  			break
  		end
  	end
  	return true
  end

  # def votes
  #   @question = Question.find(params[:id])
  #   @votes = @question.votes
  # end

end

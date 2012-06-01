class Election < ActiveRecord::Base
  attr_accessible :display_votes_as_created, :finish_time, :info, :name, :privacy, :start_time, :candidates_attributes
  
  has_many :votes, dependent: :destroy
  has_many :candidates, dependent: :destroy
  accepts_nested_attributes_for :candidates, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }

  belongs_to :user # the owner of the election
  validates_presence_of :user

  validates :start_time, presence: true
  validates :finish_time, presence: true

  validate :check_start_time, on: :create
  validate :check_finish_time, on: :create


  validates :name, presence: true, length: { within: 2..255 }

  validates :candidates, length: { minimum: 2, message: "^Election must have at least 2 candidates" }
  validate :candidates_check, on: :create


  # Privacy: true = private, false = public


  def check_start_time
    errors.add(:start_time, "^Election cannot start before now.") unless self.start_time >= 10.minutes.ago
  end

  def check_finish_time
  	if self.start_time == self.finish_time
  		errors.add(:finish_time, "^Election cannot end when it begins.")
  	elsif self.start_time > self.finish_time
  		errors.add(:finish_time, "^Election cannot end before it begins.")
  	else
  		true
  	end
  end

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


end
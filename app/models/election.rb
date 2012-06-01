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


  validates :name, presence: true
  validates :candidates, length: { minimum: 2, message: "^Election must have at least 2 candidates" } 

  # Privacy: true = private, false = public


  def check_start_time
    errors.add(:start_time, "^Election cannot start before now.") unless self.start_time >= 1.minute.ago
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

end
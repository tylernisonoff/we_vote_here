class Election < ActiveRecord::Base
  attr_accessible :dynamic, :finish_time, :info, :name, :privacy, :start_time, :questions_attributes, :emails, :voter_attributes, :valid_emails, :valid_emails_attributes
  
  has_many :questions, dependent: :destroy

  has_many :voters, dependent: :destroy
  has_many :valid_emails, dependent: :destroy

  belongs_to :user # the owner of the election

  accepts_nested_attributes_for :questions, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }
  
  accepts_nested_attributes_for :valid_emails, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }

  validates_presence_of :user

  validates :start_time, presence: true
  validates :finish_time, presence: true

  validate :check_start_time, on: :create
  validate :check_finish_time, on: :create

  validates :name, presence: true, length: { within: 2..255 }


  def check_start_time
    errors.add(:start_time, "^Election cannot start before now.") unless self.start_time + 30.minutes >= Time.now
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

  def emails
    self.valid_emails
  end

  def emails=(emails_text)
    voter_array = get_split_voters(emails_text)
    voter_array.each do |voters_emails|
      @voter = self.voters.build
      voters_emails.each do |valid_email|
        @email = self.valid_emails.build
        @email.voter = @voter
        @email.email = valid_email
      end
    end
  end

  def get_split_voters(emails_text)
    voter_array = Array.new
    split_voter_array = emails_text.split(",")
    split_voter_array.each_with_index do |voters_emails, index|
      voter_array[index] = Array.new
      split_emails_array = voters_emails.split(" ")
      split_emails_array.each do |email|
        voter_array[index].push(email)
      end
    end
    return voter_array
  end




end
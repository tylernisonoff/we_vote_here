class Group < ActiveRecord::Base
  attr_accessible :name, :privacy, :trashed, :elections_attributes, :emails, :voter_attributes, :valid_emails, :valid_emails_attributes
  
  has_many :elections, dependent: :destroy

  has_many :voters, dependent: :destroy
  has_many :valid_emails, dependent: :destroy

  belongs_to :user # the owner of the group

  accepts_nested_attributes_for :elections, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }
  
  accepts_nested_attributes_for :valid_emails, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }

  validates_presence_of :user

  validates :name, presence: true, length: { within: 2..255 }


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
        if User.exists?(email: valid_email)
          user = User.find_by_email(valid_email)
          @voter.user_id = user.id
        end
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

  def trash_group
    self.trashed = true
    self.save
  end




end
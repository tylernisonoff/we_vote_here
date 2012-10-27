class Group < ActiveRecord::Base
  attr_accessible :name, :user_id, :election_id, :emails, :voter_attributes
  
  has_many :reverse_inclusions, class_name: "Inclusion", dependent: :destroy
  has_many :elections, through: :reverse_inclusions, source: :election

  has_many :reverse_memberships, class_name: "Membership", dependent: :destroy
  has_many :voters, through: :reverse_memberships, source: :voter

  belongs_to :user # the owner of the group

  accepts_nested_attributes_for :elections, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }

  validates_presence_of :user

  validates :name, presence: true, length: { within: 2..255 }


  def emails
    ret = ""
    self.voters.each_with_index do |v, i1|
      v.valid_emails.each_with_index do |e, i2|
        ret += e.email
        if i2 + 1 < v.valid_emails.size
          ret += " "
        end
      end
      if i2 + 1 < self.voters.size
        ret += ","
      end
    end
    return ret
  end

  def emails=(emails_text)
    get_split_voters(emails_text)
  end

  # i am skeptical of this function
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

  def save_emails(emails_text)
    emails_array = emails_text.split(/[\s,]+/)
    emails_array.each do |email|
      if ValidEmail.exists?(email: email)
        valid_email = ValidEmail.find_by_email(email)
        voter = valid_email.voter
        unless Membership.exists?(group_id: self.id, voter_id: voter.id)
          membership = Membership.new
          membership.voter_id = voter.id
          membership.group_id = self.id
          membership.save
        end
      else
        voter = Voter.new
        voter.save
        membership = Membership.new
        membership.group_id = self.id
        membership.voter_id = voter.id
        membership.save
        valid_email = ValidEmail.new
        valid_email.voter_id = voter.id
        valid_email.email = email
        valid_email.save
      end
    end
  end

end
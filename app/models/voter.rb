class Voter < ActiveRecord::Base
  attr_accessible :question_id, :valid_emails_attributes

  has_many :valid_emails, dependent: :destroy

  belongs_to :group

end
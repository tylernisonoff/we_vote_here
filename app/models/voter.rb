class Voter < ActiveRecord::Base
  attr_accessible :question_id, :valid_emails_attributes

  belongs_to :election
  has_many :valid_emails, dependent: :destroy


end

class Voter < ActiveRecord::Base
  attr_accessible :question_id

  belongs_to :election
  has_many :valid_emails

end

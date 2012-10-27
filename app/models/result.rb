class Result < ActiveRecord::Base
  attr_accessible :election_id, :choice_id, :position

  belongs_to :election
  belongs_to :choice
  
  validates :election_id, presence: true
  validates :choice_id, presence: true
  validates :position, presence: true
end
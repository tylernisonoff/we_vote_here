class Candidate < ActiveRecord::Base
  attr_accessible :name

  belongs_to :election

  validates :name, presence: true
  validates :election_id, presence: true
end

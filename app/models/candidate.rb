class Candidate < ActiveRecord::Base
  attr_accessible :name, :election_id

  belongs_to :election

  validates :name, presence: true
end

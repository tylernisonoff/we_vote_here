class Choice < ActiveRecord::Base

  attr_accessible :name, :election_id

  has_one :result, dependent: :destroy
  has_many :preferences, dependent: :destroy

  belongs_to :election

  validates :name, uniqueness: {scope: [:election_id]}, presence: true, length: { minimum: 1}

end

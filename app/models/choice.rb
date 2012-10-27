class Choice < ActiveRecord::Base

  attr_accessible :name, :election_id

  has_one :result, dependent: :destroy
  has_many :preferences, dependent: :destroy

  belongs_to :election

  validates :name, presence: true, length: { minimum: 1, message: "Candidates cannot be blank"}
  validates_uniqueness_of :name, scope: [:election_id], message: "Candidates cannot have the same name"

end

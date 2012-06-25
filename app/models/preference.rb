class Preference < ActiveRecord::Base
  attr_accessible :position, :candidate_id, :vote_id

  belongs_to :vote, dependent: :destroy
  belongs_to :candidate

  validates :vote_id, presence: true
  validates :candidate_id, presence: true
  validates :position, presence: true

end
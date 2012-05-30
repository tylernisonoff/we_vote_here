class Vote < ActiveRecord::Base
  attr_accessible :vote_string

  belongs_to :user # the voter
  belongs_to :election

  validates :vote_string, presence: true
  validates :user_id, presence: true
  validates :election_id, presence: true

  default_scope order: 'votes.created_at ASC'

  def vote_array
  	vote_string.split(",")
  end

end
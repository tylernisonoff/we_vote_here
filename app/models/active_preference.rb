class ActivePreference < ActiveRecord::Base
  attr_accessible :position, :choice_id, :svc, :vote_id

  belongs_to :active_vote
  belongs_to :choice
  belongs_to :preference

  validates :svc, presence: true
  validates :vote_id, presence: true
  validates :choice_id, presence: true
  validates :position, presence: true

end
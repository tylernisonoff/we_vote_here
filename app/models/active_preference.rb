class ActivePreference < ActiveRecord::Base
  attr_accessible :position, :choice_id, :svc, :bsn

  belongs_to :active_vote, dependent: :destroy, foreign_key: :svc
  belongs_to :choice

  validates :svc, presence: true
  validates :bsn, presence: true
  validates :choice_id, presence: true
  validates :position, presence: true

end
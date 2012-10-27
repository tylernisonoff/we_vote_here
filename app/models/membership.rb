class Membership < ActiveRecord::Base
  attr_accessible :group_id, :voter_id

  belongs_to :group
  belongs_to :voter

  validates :group_id, presence: true
  validates :voter_id, presence: true
end

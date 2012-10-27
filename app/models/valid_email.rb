class ValidEmail < ActiveRecord::Base
  attr_accessible :email, :voter_id, :group_id

  belongs_to :group
  belongs_to :voter

  validates_uniqueness_of :email

end

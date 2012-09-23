class ValidEmail < ActiveRecord::Base
  attr_accessible :email, :voter_id, :group_id

  belongs_to :group
  belongs_to :voter

  
end

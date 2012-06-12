class Preference < ActiveRecord::Base
  attr_accessible :position, :candidate_id

  belongs_to :vote, dependent: :destroy
  belongs_to :question, through: :vote
  belongs_to :candidate

end

class Preference < ActiveRecord::Base
  attr_accessible :position, :candidate_id

  belongs_to :question
  belongs_to :candidate

end

class Preference < ActiveRecord::Base
  attr_accessible :position

  belongs_to :question
  belongs_to :candidate

  acts_as_list scope: :vote
end

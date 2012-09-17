class Result < ActiveRecord::Base
  attr_accessible :question_id, :choice_id, :position

  belongs_to :question
  belongs_to :choice
  
  validates :question_id, presence: true
  validates :choice_id, presence: true
  validates :position, presence: true
end
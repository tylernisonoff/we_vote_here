class Choice < ActiveRecord::Base
  attr_accessible :name, :question_id, :position

  belongs_to :question

  validates :name, presence: true, length: { minimum: 1, message: "Choices cannot be blank"}
  validates_uniqueness_of :name, scope: [:question_id], message: "Choices cannot have the same name"

end

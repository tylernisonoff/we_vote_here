class Choice < ActiveRecord::Base
  attr_accessible :name, :question_id

  belongs_to :question
  has_one :result

  validates :name, presence: true, length: { minimum: 1, message: "Candidates cannot be blank"}
  validates_uniqueness_of :name, scope: [:question_id], message: "Candidates cannot have the same name"

end

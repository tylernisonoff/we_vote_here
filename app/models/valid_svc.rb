class ValidSvc < ActiveRecord::Base
  attr_accessible :svc, :question_id

  belongs_to :question

  def to_param
  	svc
  end

  
end

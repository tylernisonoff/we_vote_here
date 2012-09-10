class ValidSvc < ActiveRecord::Base
  # require 'Random'
  attr_accessible :svc, :question_id

  belongs_to :question

  def to_param
  	svc
  end

  def assign_svc
	self.svc = return_random_svc
  end

  def return_random_svc
    # returns a random, key of integers in
    # BSN or SVC format that was not used before
    @random_svc = rand(1000000000000)
    while ValidSvc.exists?(svc: @random_key) # && !Vote.exists?(bsn: @random_key) # !|| Vote.exists?(svc: @random_key) 
    	@random_svc = rand(1000000000000)
    end

    return @random_svc
  end



  
end

class ValidSvc < ActiveRecord::Base
  attr_accessible :svc, :question_id

  belongs_to :question

  def to_param
  	svc
  end

  def assign_valid_svc
    # returns a random, key of integers in
    # BSN or SVC format that was not used before
    @random_svc = ""
    (1..18).each do |n|
      @rando = rand(10)
      @random_svc << @rando.to_s
    end

    @random_svc << self.question_id.to_s

    self.svc = @random_svc
  end

end

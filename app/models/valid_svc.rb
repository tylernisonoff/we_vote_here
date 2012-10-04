class ValidSvc < ActiveRecord::Base
  
  attr_accessible :svc, :election_id, :trashed

  belongs_to :election

  def to_param
  	svc
  end

  def assign_valid_svc
    # returns a random, key of integers in
    # BSN or SVC format that was not used before
    begin
      @random_svc = ""
      (1..18).each do |n|
        @rando = rand(10)
        @random_svc << @rando.to_s
      end
      @random_svc << self.election_id.to_s
      
      # ensure there are no collisions
    end while ValidSvc.exists?(svc: @random_svc)

    self.svc = @random_svc
  end

  def trash_valid_svc
    self.trashed = true
    self.save
  end

end

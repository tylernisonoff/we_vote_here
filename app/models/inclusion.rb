class Inclusion < ActiveRecord::Base
  attr_accessible :group_id, :election_id

  belongs_to :group
  belongs_to :election

  validates :group_id, presence: true
  validates :election_id, presence: true

  before_save :invite_voters

  def invite_voters
  	
  end


end

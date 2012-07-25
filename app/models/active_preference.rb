class ActivePreference < ActiveRecord::Base
  attr_accessible :position, :choice_id, :svc, :bsn

  belongs_to :vote, dependent: :destroy, foreign_key: :svc
  belongs_to :choice

  validates :svc, presence: true
  validates :bsn, presence: true
  validates :choice_id, presence: true
  validates :position, presence: true

  before_save { :check_timestamp }

  def check_timestamp
  	unless self.vote.question.election.record_time
  		self.timestamps = nil
  	end
  end

  # def make_inactive
  #   @preference = Preference.new
  #   @preference.bsn = self.bsn
  #   @preference.choice_id = self.choice_id
  #   @preference.position = self.position
  #   @preference.created_at = self.created_at
    
  #   @preference.save
  # end

end
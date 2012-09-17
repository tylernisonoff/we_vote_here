class Preference < ActiveRecord::Base
  
	attr_accessible :position, :choice_id, :vote_id, :svc

      has_one :active_preference, dependent: :destroy #, foreign_key: [:vote_id, :choice_id]

      belongs_to :vote
	belongs_to :choice

	validates :vote_id, presence: true
      validates :svc, presence: true
	validates :choice_id, presence: true
	validates :position, presence: true

	def make_active
            @active_preference = ActivePreference.new
            
            @active_preference.svc = self.svc
            @active_preference.vote_id = self.vote_id
            @active_preference.choice_id = self.choice_id
            @active_preference.position = self.position
            @active_preference.preference_id = self.id
            @active_preference.created_at = self.created_at

            @active_preference.save
  	end


end
class Preference < ActiveRecord::Base
  
	attr_accessible :position, :choice_id, :bsn

	belongs_to :vote, dependent: :destroy, foreign_key: :bsn
	belongs_to :choice

	validates :bsn, presence: true
	validates :choice_id, presence: true
	validates :position, presence: true

	def make_active
            @active_preference = ActivePreference.new

            @vote = Vote.find_by_bsn(bsn)
            svc = @vote.svc

            puts "\n\n\n\n\n\n#{svc}\n\n\n\n\n\n"
            
            @active_preference.svc = svc
            @active_preference.bsn = bsn
            @active_preference.choice_id = choice_id
            @active_preference.position = position
            @active_preference.created_at = self.created_at

            if @active_preference.save
                  # puts "\n\n\n\n\nSAVES\n\n\n\n"
            end
  	end


end
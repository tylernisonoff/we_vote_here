class Preference < ActiveRecord::Base
  
	attr_accessible :position, :choice_id, :vote_id, :svc, :active

      belongs_to :vote
	belongs_to :choice

	validates :vote_id, presence: true
      validates :svc, presence: true
	validates :choice_id, presence: true
	validates :position, presence: true

	def activate_preference
            self.active = true
            self.save
  	end


      def deactivate_preference
            self.active = false
            self.save
      end

      def trash_preference
            self.trashed = true
            self.save
      end


end
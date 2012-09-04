class ActiveVote < ActiveRecord::Base
	attr_accessible :question_id, :svc, :bsn

	has_many :active_preferences, foreign_key: :svc
	belongs_to :question
	
	def to_param
		svc
	end



end
class ActiveVote < ActiveRecord::Base
	attr_accessible :question_id, :svc, :vote_id

	has_many :active_preferences, dependent: :destroy, foreign_key: :svc
	
	belongs_to :vote
	belongs_to :question
	
	def to_param
		svc
	end



end
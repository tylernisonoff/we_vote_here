class PreferencesController < ApplicationController
	respond_to :html, :json

	def index
		# @active_preferences = ActivePreference.all #order('preferences.position ASC')
		@preferences = Preference.all
	end

	def sort
		unless params["choice"].blank?
			Preference.delete_all(vote_id: params[:vote_id]) 
			# delete all votes with this vote_id
			params["choice"].each_with_index do |choice_id, i|
				@preference = Preference.new
				@preference.svc = params[:svc]
				@preference.vote_id = params[:vote_id]
				@preference.choice_id = choice_id
				@preference.position = i + 1
				@preference.save
			end
			unless ActivePreference.exists?(svc: params[:svc])
				params["choice"].each_with_index do |choice_id, i|
					@active_preference = ActivePreference.new
					@active_preference.svc = params[:svc]
					@active_preference.vote_id = params[:vote_id]
					@active_preference.choice_id = choice_id
					@active_preference.position = i + 1
					@active_preference.save
				end
			end
		end
		render nothing: true
	end

end

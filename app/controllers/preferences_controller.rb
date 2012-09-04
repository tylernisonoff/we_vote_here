class PreferencesController < ApplicationController
	respond_to :html, :json

	def index
		@preferences = ActivePreference.all #order('preferences.position ASC')
	end

	def sort
		Preference.delete_all(bsn: params[:bsn]) #delete all votes with this BSN
		params["choice"].each_with_index do |choice_id, i|
			@preference = Preference.new
			@preference.bsn = params[:bsn]
			@preference.choice_id = choice_id
			@preference.position = i + 1
			@preference.save
		end
		unless ActivePreference.exists?(svc: params[:svc])
			params["choice"].each_with_index do |choice_id, i|
				@active_preference = ActivePreference.new
				@active_preference.bsn = params[:bsn]
				@active_preference.svc = params[:svc]
				@active_preference.choice_id = choice_id
				@active_preference.position = i + 1
				@active_preference.save
			end
		end
		render nothing: true
	end

end

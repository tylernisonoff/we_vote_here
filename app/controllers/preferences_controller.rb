class PreferencesController < ApplicationController
	respond_to :html, :json

	def index
		@preferences = ActivePreference.all #order('preferences.position ASC')
	end

	def sort
		puts "\n\n\n\n\n#{params}\n\n\n\n\n\n"
		Preference.delete_all(bsn: params[:bsn])
		params["choice"].each_with_index do |choice_id, i|
			@preference = Preference.new
			@preference.bsn = params[:bsn]
			@preference.choice_id = choice_id
			@preference.position = i + 1
			@preference.save
		end
		render nothing: true
	end

end

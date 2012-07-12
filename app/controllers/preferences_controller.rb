class PreferencesController < ApplicationController
	respond_to :html, :json

	def index
		@preferences = Preference.all #order('preferences.position ASC')
	end

	def sort
		vote = Vote.find_by_svc(params[:svc])
		vote_id = vote.id
		Preference.delete_all(vote_id: vote_id)
		params["candidate"].each_with_index do |cand_id, i|
			@preference = Preference.new
			@preference.vote_id = vote_id
			@preference.candidate_id = cand_id
			@preference.position = i + 1
			@preference.save
		end
		render nothing: true
	end

end

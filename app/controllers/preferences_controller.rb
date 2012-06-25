class PreferencesController < ApplicationController
	respond_to :html, :json

	def index
		@preferences = Preference.all #order('preferences.position ASC')
	end

	def sort
		print "\n\n\n\n\n\n#{params}\n\n\n\n\n\n"
		vote = Vote.find_by_svc1(params["svc1"])
		if vote
			vote_id = vote.id
		else
			vote_id = nil
		end
		params["preferences"].each_with_index do |cand_id, i|
			@preference = Preference.new
			@preference.vote_id = vote_id
			@preference.position = i + 1
			@preference.candidate_id = cand_id
			@preference.save
		end
		render nothing: true
	end

end

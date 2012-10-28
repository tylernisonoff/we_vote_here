module ElectionsHelper

	include ActionView::Helpers::UrlHelper


	def edit_election_condition(user, election)
		election.user == user
	end

	def vote_path_helper(election)
		puts "\n\n\n\n\n\n#{election}\n\n\n\n\n"
		if election.privacy
			return enter_election_valid_svcs_path(election)
		else
			return make_election_valid_svcs_path(election)
		end
	end
end

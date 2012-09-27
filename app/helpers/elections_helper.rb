module ElectionsHelper

	include ActionView::Helpers::UrlHelper


	def edit_election_condition(user, election)
		election.group.user == user
	end

	def pretty_time(time)
		if time > Time.now
			return "in #{distance_of_time_in_words_to_now(time)}"
		else
			return "#{time_ago_in_words(time)} ago"
		end
	end

	def vote_path_helper(election)
		if election.group.privacy
			return enter_election_valid_svcs_path(election)
		else
			return make_election_valid_svcs_path(election)
		end
	end
end

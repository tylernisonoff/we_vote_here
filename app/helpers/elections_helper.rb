module ElectionsHelper

	def edit_election_condition(user, election)
		election.user == user && !election.votes.any?
	end

	def pretty_name(user)
		user.nickname || user.handle
	end
end

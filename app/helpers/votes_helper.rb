module VotesHelper
	include ActionView::Helpers::UrlHelper

	def display_vote(vote, text)
  		# if vote.question.election.privacy
  		# 	return link_to text, display_private_vote_path(svc: vote.svc, id: vote.id)
  		# else
  		# 	return link_to text, display_public_vote_path(id: vote.id)
  		# end
  		return link_to text, display_public_vote_path(id: vote.id)
  	end

end
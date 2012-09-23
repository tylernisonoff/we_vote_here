module QuestionsHelper

	def edit_question_condition(user, question)
		question.group.user == user
	end



end

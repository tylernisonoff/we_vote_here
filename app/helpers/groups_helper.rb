module GroupsHelper

	def pretty_name(user)
		user.nickname || user.email
	end

	def edit_group_condition(user, group)
		group.user == user
	end

	def group_follower_condition(user, group)
		user.followed_groups.member?(group) 
	end
end

class Vote < ActiveRecord::Base
	attr_accessible :rijndael_or_user_id, :question_id

	has_many :preferences

	belongs_to :question
	
	accepts_nested_attributes_for :preferences, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }

	def preferences_check
		self.preferences.sort! { |a, b| a.position <=> b.position }
		temp = 0
		self.preferences.each do |preference|
			if temp != preference - 1
				errors.add(:preferences, "^Preferences are invalid")
			end
			temp = preference
		end
	end

end

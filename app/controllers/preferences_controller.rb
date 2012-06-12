class PreferencesController < ApplicationController

	belongs_to :vote, dependent: :allow_destroy

	# def sort
 #    	Preference.all.each do |preference|
 #      		if position = params[:preferences].index(preference.id.to_s)
 #        		preference.update_attribute(:position, position + 1) unless spec.position == position + 1
 #      		end
 #    	end
 #    	render nothing: true, :status => 200
 #  end
end

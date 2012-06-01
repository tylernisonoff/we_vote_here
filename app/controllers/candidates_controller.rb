class CandidatesController < ApplicationController
	
  respond_to :html, :json
  
  def update
  	@candidate = Candidate.find(params[:id])
	if @candidate.update_attributes(params[:candidate])
  		respond_with @candidate
  	else 
  		# render json: @candidate.errors.full_messages
  		respond_with @candidate
  	end
  end



end

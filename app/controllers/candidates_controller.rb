class CandidatesController < ApplicationController
	
  respond_to :html, :json
  
  def update
  	@candidate = Candidate.find(params[:id])
  	@candidate.update_attributes(params[:candidate])
  	respond_with @candidate
  end



end

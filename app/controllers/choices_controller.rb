class ChoicesController < ApplicationController
	
  respond_to :html, :json
  
  def update
  	@choice = Choice.find(params[:id])
	  if @choice.update_attributes(params[:choice])
  		respond_with @choice
  	else 
  		# render json: @choice.errors.full_messages
  		respond_with @choice
  	end
  end

  # eventually add the ability to trash a choice
  # def destroy
  # end



end

class ElectionsController < ApplicationController
  require 'csv'
  respond_to :html, :json

  before_filter :group_owner, only: [:new, :create, :edit, :update, :destroy]

  # eventually use this after I figure out how to make sessions with CSVs
  # before_filter :can_view, only: [:export_mov_to_csv, :export_votes_to_csv, :results, :show, :index]
  
	def new
    @group = Group.find_by_id(params[:group_id])
    @election = @group.elections.build
    @election.choices.build
    @election.choices.each do |choice|
      choice.election_id = @election.id
    end
    respond_with @election
	end

	def create
    @group = Group.find(params[:group_id])
		@election = @group.elections.build(params[:election])
		if @election.save
			flash[:success] = "Election saved"
      if params[:commit] == "Save"
			  redirect_to @group
      elsif params[:commit] == "Save and add another election"
        redirect_to new_group_election_path(@election.group)
		  end
    else
			flash[:failure] = "Failed to save election"
		end

    # If the group is private, then create SVCs
    # This also sends an email to every valid email with their SVC
    @election.send_election_emails
	end

	def edit
		@election = Election.find(params[:id])
	end

	def show
    @election = Election.find(params[:id])
    @votes = Vote.find(:all, conditions: {election_id: @election.id, tie_breaking: false, active: true})
  end

  def destroy
  	@election.trash_election
  	redirect_to root_path
  end

  def index
    if params[:group_id]
      @group_id = params[:group_id]
      @elections = Election.find(:all, conditions: {group_id: params[:group_id], trashed: false})
    else
      @elections = Election.find(:all, conditions: {privacy: false, trashed: false})
    end
  end

  def update
    if @election.update_attributes(params[:election])
      flash[:success] = "Election updated"
      redirect_to @election
    else
      render 'edit'
    end
  end

  def results
    @election = Election.find(params[:id])
    # @sorted_mov = 
    if @election.start_time < Time.now
      @results_array = @election.choice_name_array(true)
      @tie_breaking_vote = Vote.find(:first, conditions: {svc: @election.id.to_s, tie_breaking: true})
      puts "TBV: #{@tie_breaking_vote}"
      @tie_breaking_preferences = Preference.find(:all, conditions: {svc: @election.id.to_s, tie_breaking: true})
      @tie_breaking_preferences.sort_by { |p| p.position }
      puts "TBP: #{@tie_breaking_preferences}"
    end
  end

  def export_mov_to_csv
    @election = Election.find(params[:id])

    if params[:sorted] == "1"
      sorted = true
    else
      sorted = false
    end

    if params[:adjusted] == "1"
      adjusted = true
    else
      adjusted = false
    end

    @mov = @election.get_mov(adjusted)

    if sorted && adjusted
      filename ="sorted_adjusted_mov_for_#{adjusted_filename(@election)}"
    elsif sorted
      filename ="sorted_mov_for_#{adjusted_filename(@election)}"
    elsif adjusted
      filename ="adjusted_mov_for_#{adjusted_filename(@election)}"
    else
      filename ="regular_mov_for_#{adjusted_filename(@election)}"
    end

    @choice_names = @election.choice_name_array(sorted)
    @choice_ids = @election.choice_id_array(sorted)
    
    csv_data = CSV.generate do |csv|
      csv << (["Choice"] + @choice_names)
      @choice_names.each_with_index do |choice_name, index|
        add_to_csv = [choice_name]
        @choice_ids.each do |choice_id|
          add_to_csv.push(@mov[@choice_ids[index]][choice_id])
        end
        csv << add_to_csv
      end
    end

    send_data csv_data,
      type: 'text/csv; charset=iso-8859-1; header=present',
      disposition: "attachment; filename=#{filename}.csv"
  end

  def export_votes_to_csv
    @election = Election.find(params[:id])
    @votes_hash = @election.get_active_votes_hash

    @choice_names = @election.choice_name_array
    @choice_ids = @election.choice_id_array
    filename ="active_votes_for_#{adjusted_filename(@election)}"

    csv_data = CSV.generate do |csv|
      csv << (["BSN"] + @choice_names)
      @votes_hash.each do |vote_id, vote_hash|  
        add_to_csv = [vote_id]
        @choice_ids.each do |choice_id|
          add_to_csv.push(vote_hash[choice_id])
        end
        csv << add_to_csv
      end
      csv << (["TBV"] + @election.get_tbv_array)
    end

    send_data csv_data,
      type: 'text/csv; charset=iso-8859-1; header=present',
      disposition: "attachment; filename=#{filename}.csv"
  end

  def export_ranked_pairs_to_txt
    @election = Election.find(params[:id])

    text_array = @election.ranked_pairs(true, true, true)

    filename ="ranked_pairs_for_#{adjusted_filename(@election)}"

    txt_data = "Ranked Pairs for #{@election.name}\n"
    text_array.each do |text|
      txt_data = txt_data + text + "\n"
    end

    send_data txt_data, filename: "ranked_pairs_for_#{adjusted_filename(@election)}.txt"
  end

  private

  def group_owner
    if params[:group_id]
      if Group.exists?(params[:group_id])
        @group = Group.find(params[:group_id])
        if current_user == @group.user
          return true
        else
          flash[:error] = "You cannot edit this election because you don't own it :/"
          redirect_back_or root_path
        end
      else
        flash[:error] = "Sorry, that group doesn't exist"
      end
    elsif params[:id]
      if Election.exists?(params[:id])
        @election = Election.find(params[:id])
        if current_user == @election.group.user
          return true 
        else
          flash[:error] = "You cannot edit this election because you don't own it :/"
          redirect_back_or root_path
        end
      else
        flash[:error] = "Sorry, that election doesn't exist"
      end
    else
      flash[:error] = "You cannot edit this election because we're not sure if you own it :/"
      redirect_back_or root_path
    end
  end

  def can_view
    election = Election.find(params[:id])
    if !election.group.privacy || ValidSvc.exists?(svc: params[:svc])
      return true
    else
      flash[:error] = "You need a valid SVC to do this."
      redirect_back_or root_path
      return false
    end
  end

  def adjusted_filename(election)
    split_name_array = Array.new
    split_name_array.append(election.id)
    split_name_array = split_name_array + election.name.split(" ")
    new_name = split_name_array.join('_')
    return new_name
  end
end

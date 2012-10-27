class ElectionsController < ApplicationController
  require 'csv'
  respond_to :html, :json

  before_filter :election_owner, only: [:edit, :update, :destroy]

  # eventually use this after I figure out how to make sessions with CSVs
  # before_filter :can_view, only: [:export_mov_to_csv, :export_votes_to_csv, :results, :show, :index]
  
	def new
    @election = Election.new
    @election.choices.build
    @election.choices.each do |choice|
      choice.election_id = @election.id
    end
    respond_with @election
	end

	def create
		@election = current_user.elections.build(params[:election])
		if @election.save
			flash[:success] = "Election saved"
      redirect_to add_parties_election_path(@election)
      # If the group is private, then create SVCs
      # This also sends an email to every valid email with their SVC
      @election.send_election_emails
    else
			flash[:failure] = "Failed to save election. Try again"
      render 'new'
		end
	end

	def edit
		@election = Election.find(params[:id])
	end

	def show
    @election = Election.find(params[:id])
    @votes = Vote.find(:all, conditions: {election_id: @election.id, active: true})
  end

  def destroy
    if @election.destroy
      flash[:success] = "Successfully destroyed election."
      redirect_to root_path
    else
      flash[:error] = "We were unable to destroy this election."
  	  redirect_to @election
    end
  end

  def index
    if params[:group_id]
      @group = Group.find(params[:group_id])
      @elections = @group.elections
    else
      @elections = Election.all
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
    end
  end

  def add_groups
    @election = Election.find(params[:election_id])
    @election_groups = @election.groups
    @followed_groups = current_user.followed_groups - @election_groups
    @users_groups = current_user.groups - @election_groups
  end

  def save_groups
    @election = Election.find(params[:election_id])
    saved_all = true
    groups_hash = params[:group]
    groups_hash.each do |gid, bin|
      if bin == "1"
        voter_array_before = @election.get_voter_array
        inclusion = Inclusion.new
        inclusion.election_id = @election.id
        inclusion.group_id = gid
        if !inclusion.save
          saved_all = false
        elsif @election.finish_time > Time.now
          voter_array_after = @election.get_voter_array
          voter_array_diff = voter_array_after - voter_array_before
          @election.send_election_emails
        end
      end
    end
    if saved_all
      flash[:success] = "Successfully included all new groups"
      redirect_to @election
    else
      flash[:error] = "Failed to include some groups. Try again"
      redirect_to add_groups_election_path(@election)
    end
  end

  def export
    @election = Election.find(params[:id])
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

    text_array = @election.ranked_pairs(true)

    filename ="ranked_pairs_for_#{adjusted_filename(@election)}"

    txt_data = "Ranked Pairs for #{@election.name}\n"
    text_array.each do |text|
      txt_data = txt_data + text + "\n"
    end

    send_data txt_data, filename: "ranked_pairs_for_#{adjusted_filename(@election)}.txt"
  end

  private

  def election_owner
    if params[:id]
      if Election.exists?(params[:id])
        @election = Election.find(params[:id])
        if current_user == @election.user
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
  
  def adjusted_filename(election)
    split_name_array = Array.new
    split_name_array.append(election.id)
    split_name_array = split_name_array + election.name.split(" ")
    new_name = split_name_array.join('_')
    return new_name
  end
end

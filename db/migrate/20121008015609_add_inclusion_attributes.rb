class AddInclusionAttributes < ActiveRecord::Migration
  def change
  	add_column :inclusions, :group_id, :integer
  	add_column :inclusions, :election_id, :integer

  	change_column :inclusions, :group_id, :integer, null: false
  	change_column :inclusions, :election_id, :integer, null: false
  	
  end
end

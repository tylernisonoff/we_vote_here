class FixCandidates < ActiveRecord::Migration
  def up
  	change_column :candidates, :name, :string, null: false
	change_column :candidates, :election_id, :integer, null: false
  	
  	add_index :candidates, [:election_id, :name], unique: true
  end

  def down
  	change_column :candidates, :name, :string
	change_column :candidates, :election_id, :integer
  	
  	remove_index :candidates, [:election_id, :name]
  end
end

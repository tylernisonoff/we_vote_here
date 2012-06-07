class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
    	t.integer :vote_id, null: false
    	t.integer :election_id, null: false
    	t.integer :candidate_id, null: false
    	t.integer :position, null: false

      	t.timestamps
    end

    add_index :preferences, [:vote_id, :candidate_id], unique: true
    add_index :preferences, [:vote_id, :position], unique: true

  end
end

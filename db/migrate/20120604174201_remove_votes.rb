class RemoveVotes < ActiveRecord::Migration
  def up
  	drop_table(:votes)
  end

  def down
  	create_table :votes do |t|
    	t.integer :election_id, null: false
    	t.string :rijndael_or_user_id, null: false

      	t.timestamps
    end
  end
end
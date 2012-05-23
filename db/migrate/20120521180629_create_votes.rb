class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
    	t.string :vote_string

      	t.timestamps
    end
  end
end

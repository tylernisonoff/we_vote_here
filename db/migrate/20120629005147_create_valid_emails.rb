class CreateValidEmails < ActiveRecord::Migration
  def change
    create_table :valid_emails do |t|
    	t.string :email, null: false
    	t.integer :voter_id, null: false
    	t.integer :question_id, null: false

      t.timestamps
    end

    add_index :valid_emails, :email, unique: true
  end
end

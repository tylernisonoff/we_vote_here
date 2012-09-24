class CreateUserEmails < ActiveRecord::Migration
  def change
    create_table :user_emails do |t|
    	t.integer :user_id, null: false
    	t.string :email, null: false

      t.timestamps
    end

    add_index :user_emails, :user_id
    add_index :user_emails, :email, unique: true

  end
end

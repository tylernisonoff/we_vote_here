class AddTrashedToValidEmail < ActiveRecord::Migration
  def change
  	add_column :valid_emails, :trashed, :boolean, default: false
  end
end

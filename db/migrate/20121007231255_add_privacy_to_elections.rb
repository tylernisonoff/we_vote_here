class AddPrivacyToElections < ActiveRecord::Migration
  def change
  	add_column :elections, :privacy, :boolean, default: true
  end
end

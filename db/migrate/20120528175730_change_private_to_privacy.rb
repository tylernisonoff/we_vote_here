class ChangePrivateToPrivacy < ActiveRecord::Migration
  def up
  	remove_column :elections, :private
  	add_column :elections, :privacy, :boolean, { null: false, default: true }
  end

  def down
  	remove_column :elections, :privacy
  	add_column :elections, :private, :boolean, { null: false, default: true }
  end
end

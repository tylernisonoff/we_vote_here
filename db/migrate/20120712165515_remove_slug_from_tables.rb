class RemoveSlugFromTables < ActiveRecord::Migration
  def change
  	remove_column :valid_svcs, :slug
  	remove_column :votes, :slug
  end
end

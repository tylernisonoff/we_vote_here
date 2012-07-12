class AddSlugToValidSvcs < ActiveRecord::Migration
  def change
  	add_column :valid_svcs, :slug, :string
  end
end

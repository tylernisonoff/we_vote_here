class AddSlugToSvc < ActiveRecord::Migration
  def change
  	add_column :valid_svcs, :slug, :string

  	add_index :valid_svcs, :slug, unique: true
  end
end

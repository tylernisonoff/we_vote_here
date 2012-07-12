class AddSlugToVotes < ActiveRecord::Migration
  def change
  	add_column :votes, :slug, :string

  	add_index :votes, :slug, unique: true
  end
end

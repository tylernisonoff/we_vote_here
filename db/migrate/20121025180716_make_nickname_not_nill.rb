class MakeNicknameNotNill < ActiveRecord::Migration
  def change
  	add_column :users, :nickname, :string, default: "", null: false
  end
end

class AddIndexOnSvc < ActiveRecord::Migration
  def change
  	add_index :votes, :svc
  end
end

class RemoveSvc < ActiveRecord::Migration
  def change
  	drop_table :svcs
  end
end

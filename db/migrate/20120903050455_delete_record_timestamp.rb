class DeleteRecordTimestamp < ActiveRecord::Migration
  def change
  	remove_column :elections, :record_time
  end
end

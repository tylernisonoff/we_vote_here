class CreateElections < ActiveRecord::Migration
  def change
    create_table :elections do |t|
      t.timestamp :finish_time
      t.text :info
      t.string :name
      t.integer :privacy
      t.timestamp :start_time
      t.integer :user_id

      t.timestamps
    end
  end
end

class CreateValidSvcs < ActiveRecord::Migration
  def change
    create_table :valid_svcs do |t|
    	t.string :svc, null: false
    	t.integer :question_id, null: false

      t.timestamps
    end

    add_index :valid_svcs, [:svc, :question_id], unique: true
  end
end

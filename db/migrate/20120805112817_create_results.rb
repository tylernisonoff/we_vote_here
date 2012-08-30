class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
    	t.integer :question_id
    	t.integer :choice_id
    	t.integer :position

      t.timestamps

    end
    add_index :results, [:question_id, :position], unique: true
    add_index :results, [:question_id, :choice_id], unique: true

  end
end

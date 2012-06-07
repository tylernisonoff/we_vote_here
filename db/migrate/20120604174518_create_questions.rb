class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
    	t.string :name, null: false
    	t.text :info

      	t.timestamps
    end
  end
end

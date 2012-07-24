class CreateInactivePreferences < ActiveRecord::Migration
  def change
    create_table :inactive_preferences do |t|
    	t.integer :choice_id, null: false
    	t.string :bsn, null: false
    	t.integer :position, null: false
      t.timestamps
    end
  end
end

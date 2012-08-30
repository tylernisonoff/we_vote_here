class RemoveIndexOnPositionForAllPrefs < ActiveRecord::Migration
  def change
  	remove_index :active_preferences, :name => "index_preferences_on_svc_and_position"

  	
  	remove_index :active_preferences, :name => "index_preferences_on_svc_and_choice_id"
  	add_index :active_preferences, [:svc, :choice_id], unique: true

  	remove_index :choices, :name => "index_choices_on_question_id_and_position"


  	remove_index :preferences, :name => "index_inactive_preferences_on_bsn_and_choice_id"
  	remove_index :preferences, :name => "index_inactive_preferences_on_bsn_and_position"

  	add_index :preferences, [:bsn, :choice_id], unique: true

  	remove_index :results, :name => "index_results_on_question_id_and_position"
  end
end

class CreateActiveVotes < ActiveRecord::Migration
  def change
    create_table :active_votes do |t|
		t.integer :question_id
		t.string :svc
		t.string :bsn
      t.timestamps
    end
  end
end

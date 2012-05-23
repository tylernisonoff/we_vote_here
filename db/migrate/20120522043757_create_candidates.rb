class CreateCandidates < ActiveRecord::Migration
  def change
    create_table :candidates do |t|
      t.integer :election_id
      t.string :name

      t.timestamps
    end
  end
end

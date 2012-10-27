class CreateInclusions < ActiveRecord::Migration
  def change
    create_table :inclusions do |t|

      t.timestamps
    end

    add_column :elections, :user_id, :integer

  end
end

# didn't work
class LoadElections < ActiveRecord::Migration
  def change
    elections = Election.all
    elections.each do |e|
        e.user_id = e.group.user_id
    end
  end
end
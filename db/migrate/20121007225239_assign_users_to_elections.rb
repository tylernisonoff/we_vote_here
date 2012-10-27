# still doesn't work... user heroku console.
class LoadElections < ActiveRecord::Migration
  def change
    elections = Election.all
    elections.each do |e|
        group = e.group
        e.user_id = group.id
        print e.user_id
        e.save
    end
  end
end

class AssignUsersToElections < ActiveRecord::Migration
  def up
  end

  def down
  end
end

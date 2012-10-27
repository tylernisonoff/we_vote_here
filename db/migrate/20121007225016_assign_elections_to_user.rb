# didn't work.
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

class AssignElectionsToUser < ActiveRecord::Migration
  def change

  end
end

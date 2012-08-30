class RemovePositionFromChoices < ActiveRecord::Migration
  def change
  	remove_column :choices, :position
  end
end

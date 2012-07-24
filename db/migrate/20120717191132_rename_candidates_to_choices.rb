class RenameCandidatesToChoices < ActiveRecord::Migration
    def self.up
        rename_table :candidates, :choices
    end 
    def self.down
        rename_table :choices, :candidates
    end
 end
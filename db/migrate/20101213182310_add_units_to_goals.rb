class AddUnitsToGoals < ActiveRecord::Migration
  def self.up
    add_column :goals, :units, :string
  end

  def self.down
    remove_column :goals, :units
  end
end

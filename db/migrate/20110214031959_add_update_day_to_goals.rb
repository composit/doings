class AddUpdateDayToGoals < ActiveRecord::Migration
  def self.up
    add_column :goals, :update_day, :integer
  end

  def self.down
    remove_column :goals, :update_day
  end
end

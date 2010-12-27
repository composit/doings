class AddWeekdayToGoals < ActiveRecord::Migration
  def self.up
    add_column :goals, :weekday, :integer
  end

  def self.down
    remove_column :goals, :weekday
  end
end

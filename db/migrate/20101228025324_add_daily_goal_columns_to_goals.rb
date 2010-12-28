class AddDailyGoalColumnsToGoals < ActiveRecord::Migration
  def self.up
    add_column :goals, :type, :string
    add_column :goals, :master_goal_id, :integer
    add_column :goals, :daily_date, :date
    add_column :goals, :previously_completed_amount, :float
  end

  def self.down
    remove_column :goals, :type
    remove_column :goals, :master_goal_id
    remove_column :goals, :daily_date
    remove_column :goals, :previously_completed_amount
  end
end

class UpdateDailyGoalColumnsInGoals < ActiveRecord::Migration
  def self.up
    remove_column :goals, :type
    remove_column :goals, :master_goal_id
    rename_column :goals, :previously_completed_amount, :daily_previously_completed_amount
    add_column :goals, :daily_goal_amount, :float
  end

  def self.down
    add_column :goals, :type, :string
    add_column :goals, :master_goal_id, :integer
    rename_column :goals, :daily_previously_completed_amount, :previously_completed_amount
    remove_column :goals, :daily_goal_amount
  end
end

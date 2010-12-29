class RemovePreviouslyCompletedAmountFromGoals < ActiveRecord::Migration
  def self.up
    remove_column :goals, :daily_previously_completed_amount
  end

  def self.down
    add_column :goals, :daily_previously_completed_amount, :float
  end
end

class RenameEstimatedHourlyRateToHourlyRateForCalculations < ActiveRecord::Migration
  def self.up
    rename_column :billing_rates, :estimated_hourly_rate, :hourly_rate_for_calculations
  end

  def self.down
    rename_column :billing_rates, :hourly_rate_for_goals, :estimated_hourly_rate
  end
end

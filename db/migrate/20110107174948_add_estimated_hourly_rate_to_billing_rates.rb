class AddEstimatedHourlyRateToBillingRates < ActiveRecord::Migration
  def self.up
    add_column :billing_rates, :estimated_hourly_rate, :decimal, :scale => 2, :precision => 10
  end

  def self.down
    remove_column :billing_rates, :estimated_hourly_rate
  end
end

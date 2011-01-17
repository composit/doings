class AddBillingRateIdToModelsWithBillingRates < ActiveRecord::Migration
  def self.up
    add_column :clients, :billing_rate_id, :integer
    add_column :projects, :billing_rate_id, :integer
    add_column :tickets, :billing_rate_id, :integer
  end

  def self.down
    remove_column :clients, :billing_rate_id
    remove_column :projects, :billing_rate_id
    remove_column :tickets, :billing_rate_id
  end
end

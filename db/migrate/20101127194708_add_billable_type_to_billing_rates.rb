class AddBillableTypeToBillingRates < ActiveRecord::Migration
  def self.up
    add_column :billing_rates, :billable_type, :string
  end

  def self.down
    remove_column :billing_rates, :billable_type
  end
end

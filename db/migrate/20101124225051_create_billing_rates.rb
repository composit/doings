class CreateBillingRates < ActiveRecord::Migration
  def self.up
    create_table :billing_rates do |t|
      t.integer :billable_id
      t.decimal :dollars, :precision => 10, :scale => 2
      t.string :units

      t.timestamps
    end
  end

  def self.down
    drop_table :billing_rates
  end
end

class CreateInvoiceAdjustments < ActiveRecord::Migration
  def self.up
    create_table :invoice_adjustments do |t|
      t.string :description
      t.decimal :amount, :precision => 10, :scale => 2
      t.references :invoice

      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_adjustments
  end
end

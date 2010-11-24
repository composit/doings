class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.integer :client_id
      t.integer :created_by_user_id
      t.date :invoice_date
      t.datetime :paid_at
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end

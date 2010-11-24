class CreateClients < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.string :name
      t.string :web_address
      t.integer :address_id
      t.string :billing_frequency
      t.boolean :active

      t.timestamps
    end
  end

  def self.down
    drop_table :clients
  end
end

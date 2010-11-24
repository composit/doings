class AddLoginAddressTimeZoneToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :login, :string
    add_column :users, :address_id, :integer
    add_column :users, :time_zone, :string
  end

  def self.down
    remove_column :users, :login
    remove_column :users, :address_id
    remove_column :users, :time_zone
  end
end

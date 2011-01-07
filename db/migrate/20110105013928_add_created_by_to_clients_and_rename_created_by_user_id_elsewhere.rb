class AddCreatedByToClientsAndRenameCreatedByUserIdElsewhere < ActiveRecord::Migration
  def self.up
    add_column :clients, :created_by_user_id, :integer
  end

  def self.down
    remove_column :clients, :created_by_user_id
  end
end

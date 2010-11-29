class AddManageableTypeToUserRoles < ActiveRecord::Migration
  def self.up
    add_column :user_roles, :manageable_type, :string
  end

  def self.down
    remove_column :user_roles, :manageable_type
  end
end

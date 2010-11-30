class RenameViewerToAdminInUserRoles < ActiveRecord::Migration
  def self.up
    rename_column :user_roles, :viewer, :admin
  end

  def self.down
    rename_column :user_roles, :admin, :viewer
  end
end

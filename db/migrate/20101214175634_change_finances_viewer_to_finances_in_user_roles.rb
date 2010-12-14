class ChangeFinancesViewerToFinancesInUserRoles < ActiveRecord::Migration
  def self.up
    rename_column :user_roles, :finances_viewer, :finances
  end

  def self.down
    rename_column :user_roles, :finances, :finances_viewer
  end
end

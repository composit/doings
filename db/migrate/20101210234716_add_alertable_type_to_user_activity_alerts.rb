class AddAlertableTypeToUserActivityAlerts < ActiveRecord::Migration
  def self.up
    add_column :user_activity_alerts, :alertable_type, :string
  end

  def self.down
    remove_column :user_activity_alerts, :alertable_type
  end
end

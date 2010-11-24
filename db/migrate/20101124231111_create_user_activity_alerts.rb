class CreateUserActivityAlerts < ActiveRecord::Migration
  def self.up
    create_table :user_activity_alerts do |t|
      t.integer :user_id
      t.integer :alertable_id
      t.text :content
      t.datetime :dismissed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :user_activity_alerts
  end
end

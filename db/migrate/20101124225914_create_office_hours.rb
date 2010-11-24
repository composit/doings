class CreateOfficeHours < ActiveRecord::Migration
  def self.up
    create_table :office_hours do |t|
      t.integer :workable_id
      t.integer :worker_id
      t.integer :day_of_week
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end

  def self.down
    drop_table :office_hours
  end
end

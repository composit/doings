class GetRidOfOfficeHours < ActiveRecord::Migration
  def self.up
    drop_table :office_hours
  end

  def self.down
    create_table :office_hours do |t|
      t.integer :workable_id
      t.integer :worker_id
      t.integer :day_of_week
      t.time :start_time
      t.time :end_time

      t.timestamps
      t.string :workable_type
    end
  end
end

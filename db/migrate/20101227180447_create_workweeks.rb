class CreateWorkweeks < ActiveRecord::Migration
  def self.up
    create_table :workweeks do |t|
      t.integer :worker_id
      t.boolean :sunday
      t.boolean :monday
      t.boolean :tuesday
      t.boolean :wednesday
      t.boolean :thursday
      t.boolean :friday
      t.boolean :saturday

      t.timestamps
    end
  end

  def self.down
    drop_table :workweeks
  end
end

class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.integer :project_id
      t.integer :created_by_user_id
      t.string :name
      t.datetime :closed_at
      t.integer :estimated_minutes

      t.timestamps
    end
  end

  def self.down
    drop_table :tickets
  end
end

class CreateGoals < ActiveRecord::Migration
  def self.up
    create_table :goals do |t|
      t.integer :user_id
      t.integer :workable_id
      t.string :workable_type
      t.string :period
      t.integer :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :goals
  end
end

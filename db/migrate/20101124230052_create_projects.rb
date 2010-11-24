class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.integer :client_id
      t.integer :created_by_user_id
      t.string :name
      t.datetime :closed_at
      t.integer :closed_by_user_id
      t.integer :authorized_by_user_id
      t.datetime :authorized_at
      t.boolean :urgent

      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end

class CreateUserRoles < ActiveRecord::Migration
  def self.up
    create_table :user_roles do |t|
      t.integer :user_id
      t.integer :manageable_id
      t.boolean :worker
      t.boolean :authorizer
      t.boolean :viewer
      t.boolean :finances_viewer
      t.boolean :invoicer
      t.integer :priority

      t.timestamps
    end
  end

  def self.down
    drop_table :user_roles
  end
end

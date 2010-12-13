class AddNameToGoals < ActiveRecord::Migration
  def self.up
    add_column :goals, :name, :string
  end

  def self.down
    remove_column :goals, :name
  end
end

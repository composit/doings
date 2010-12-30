class AddPriorityToGoals < ActiveRecord::Migration
  def self.up
    add_column :goals, :priority, :integer
  end

  def self.down
    remove_column :goals, :priority
  end
end

class ChangeGoalAmountToDecimal < ActiveRecord::Migration
  def self.up
    change_column :goals, :amount, :decimal, :scale => 2, :precision => 10
  end

  def self.down
    change_column :goals, :amount, :integer
  end
end

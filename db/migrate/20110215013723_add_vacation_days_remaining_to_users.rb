class AddVacationDaysRemainingToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :vacation_days_remaining, :integer
  end

  def self.down
    remove_column :users, :vacation_days_remaining
  end
end

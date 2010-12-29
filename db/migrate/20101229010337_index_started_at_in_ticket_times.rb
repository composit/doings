class IndexStartedAtInTicketTimes < ActiveRecord::Migration
  def self.up
    add_index :ticket_times, :started_at
  end

  def self.down
    remove_index :ticket_times, :started_at
  end
end

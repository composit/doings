class CreateTicketTimes < ActiveRecord::Migration
  def self.up
    create_table :ticket_times do |t|
      t.integer :worker_id
      t.integer :ticket_id
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :invoice_id

      t.timestamps
    end
  end

  def self.down
    drop_table :ticket_times
  end
end

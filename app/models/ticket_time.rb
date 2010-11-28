class TicketTime < ActiveRecord::Base
  belongs_to :worker, :class_name => 'User'
  belongs_to :ticket
  belongs_to :invoice

  validates :started_at, :presence => true
  validates :ended_at, :chronological_times => true
end

class TicketTime < ActiveRecord::Base
  belongs_to :worker, :class_name => 'User'
  belongs_to :ticket
  belongs_to :invoice

  validates :started_at, :presence => true
  validates :ended_at, :chronological_times => true
  validates :worker_id, :presence => true
  validates :ticket_id, :presence => true

  before_validation :set_start_time, :on => :create
  before_validation :close_open_ticket_times

  attr_accessor :stop_now

  def stop_now=( stop )
    self.ended_at = Time.zone.now if( stop == "1" )
  end

  def seconds_worked
    if( ended_at.nil? )
      seconds = Time.zone.now - started_at
    else
      seconds = ended_at - started_at
    end
    return( seconds )
  end

  def dollars_earned
    if( ticket.billing_rate.units == "hour" )
      earned = seconds_worked * ticket.billing_rate.dollars / 3600
    end
    return( earned )
  end

  def self.batch_minutes_worked( times )
    times.inject( 0 ) { |sum, time| sum + time.seconds_worked } / 60
  end

  def self.batch_dollars_earned( times )
    times.inject( 0 ) { |sum, time| sum + time.dollars_earned }
  end

  private
    def set_start_time
      self.started_at ||= Time.zone.now
    end

    def close_open_ticket_times
      if( worker && ended_at.nil? )
        worker.ticket_times.where( "ended_at is null" ).each do |ticket_time|
          unless( ticket_time.update_attributes( :ended_at => started_at ) )
            self.errors[:worker] << "has a currently open ticket time with a future start date. Please close it before opening a new ticket."
          end
        end
      end
    end
end

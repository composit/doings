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
  before_save :split_wrapping_times
  after_save :update_goals

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
    earned = seconds_worked * ticket.billing_rate.hourly_rate_for_calculations / 3600
    if( ticket.billing_rate.units == "hour" )
      return( earned )
    else
      dollars_remaining = ticket.billing_rate.dollars_remaining( started_at )
      return( earned > dollars_remaining ? dollars_remaining : earned )
    end
  end

  def self.batch_seconds_worked( times )
    times.inject( 0.0 ) { |sum, time| sum + time.seconds_worked }
  end

  def self.batch_dollars_earned( times )
    times.inject( 0.0 ) { |sum, time| sum + time.dollars_earned }
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

    def split_wrapping_times
      if( started_at && ended_at && started_at.yday != ended_at.yday )
        final_ended_at = ended_at
        self.ended_at = started_at.end_of_day
        intermediate_days = ( ( final_ended_at - started_at ) / 86400 ).to_i
        ticket_time_attrs = attributes.reject { |key, value| [ "created_at", "updated_at" ].include?( key ) }
        #create ticket times for each day between starting and ending date
        intermediate_days.times do |day|
          TicketTime.create!( ticket_time_attrs.merge( "started_at" => ( started_at + ( day + 1 ).days ).beginning_of_day, "ended_at" => ( started_at + ( day + 1 ).days ).end_of_day ) )
        end
        #create ticket time for the last day
        TicketTime.create!( ticket_time_attrs.merge( "started_at" => final_ended_at.beginning_of_day, "ended_at" => final_ended_at ) )
      end
    end

    def update_goals
      # update goals: previously completed amount
      worker.goals.each { |goal| goal.save! } if( started_at < Time.zone.now.beginning_of_day )
    end
end

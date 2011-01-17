class BillingRate < ActiveRecord::Base
  belongs_to :billable, :polymorphic => true

  UNIT_OPTIONS = ["hour", "month", "project"]

  validates :dollars, :numericality => true
  validates :units, :inclusion => { :in => UNIT_OPTIONS, :message => "are not included in the list" }

  before_validation :assign_hourly_rate_for_calculations

  def description
    "$#{formatted_dollars}/#{units}"
  end

  def previous_dollars_earned( time = Time.zone.now )
    applicable_ticket_times = billable.ticket_times.where( "started_at < ?", time )
    applicable_ticket_times = applicable_ticket_times.where( "started_at >= ?", Time.zone.now.beginning_of_month ) if( units == "month" )
    calculated_total = TicketTime.batch_seconds_worked( applicable_ticket_times ) / 3600 * hourly_rate_for_calculations
    if( units == "hour" )
      return( calculated_total )
    else
      return( calculated_total > dollars ? dollars : calculated_total )
    end
  end

  private
    def formatted_dollars
      if( dollars % 1 == 0 )
        return( dollars.to_i )
      else
        return( sprintf( "%.2f", dollars ) )
      end
    end

    def assign_hourly_rate_for_calculations
      self.hourly_rate_for_calculations = dollars if( units == "hour" )
    end
end

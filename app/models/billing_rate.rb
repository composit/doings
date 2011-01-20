class BillingRate < ActiveRecord::Base
  belongs_to :billable, :polymorphic => true
  has_one :client
  has_one :project
  has_one :ticket

  UNIT_OPTIONS = ["hour", "month", "total"]

  validates :dollars, :numericality => true
  validates :units, :inclusion => { :in => UNIT_OPTIONS, :message => "are not included in the list" }

  before_validation :assign_hourly_rate_for_calculations, :assign_billable

  def description
    desc_string = "$#{formatted_dollars}"
    desc_string += "/#{units}" unless( units == "total" )
    desc_string += " for #{billable.name}" unless( units == "hour" )
    return( desc_string )
  end

  def dollars_remaining( time = Time.zone.now )
    applicable_ticket_times = billable.ticket_times.where( "started_at < ?", time )
    applicable_ticket_times = applicable_ticket_times.where( "started_at >= ?", Time.zone.now.beginning_of_month ) if( units == "month" )
    calculated_total = TicketTime.batch_seconds_worked( applicable_ticket_times ) / 3600 * hourly_rate_for_calculations
    raw_remaining = dollars - calculated_total
    return( raw_remaining > 0 ? raw_remaining : 0.0 )
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

    def assign_billable
      unless( billable )
        self.billable = client if client
        self.billable = project if project
        self.billable = ticket if ticket
      end
    end
end

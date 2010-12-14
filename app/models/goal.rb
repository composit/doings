class Goal < ActiveRecord::Base
  belongs_to :user
  belongs_to :workable, :polymorphic => true

  WORKABLE_TYPES = ["Client", "Project", "Ticket"]
  PERIODS = ["Yearly", "Monthly", "Weekly", "Daily"]
  UNITS = ["minutes", "dollars"]

  validates :name, :presence => true
  validates :amount, :presence => true, :numericality => true
  validates :workable_type, :inclusion => { :in => WORKABLE_TYPES }, :allow_blank => true
  validates :period, :presence => true, :inclusion => { :in => PERIODS }
  validates :units, :presence => true, :inclusion => { :in => UNITS }

  def full_description
    desc = "#{name}: #{amount_string}/#{period_unit}"
    desc += " for #{workable.name}" if( workable_id )
    return desc
  end

  def percent_complete
    if( units == "minutes" )
      fraction = TicketTime.batch_minutes_worked( applicable_ticket_times ) / amount
    elsif( units == "dollars" )
      fraction = TicketTime.batch_dollars_earned( applicable_ticket_times ) / amount
    end
    return( fraction > 1 ? 100 : ( fraction * 100 ).round )
  end

  def applicable_ticket_times
    case period
      when "Daily"
        start_time = Time.zone.now.beginning_of_day
        end_time = start_time + 1.day
      when "Weekly"
        start_time = Time.zone.now.beginning_of_week
        end_time = start_time + 1.week
      when "Monthly"
        start_time = Time.zone.now.beginning_of_month
        end_time = start_time + 1.month
      when "Yearly"
        start_time = Time.zone.now.beginning_of_year
        end_time = start_time + 1.year
    end
    if( workable_id.nil? )
      ticket_times = TicketTime
    else
      ticket_times = workable.ticket_times
    end
    ticket_times = ticket_times.where( :worker_id => user.id ).where( "started_at >= ? and started_at < ?", start_time, end_time )
  end

  private
    def period_unit
      case period
        when "Yearly" then "year"
        when "Monthly" then "month"
        when "Weekly" then "week"
        when "Daily" then "day"
      end
    end

    def amount_string
      if( amount % 1 == 0 )
        formatted_amount = amount.to_i
      else
        formatted_amount = sprintf( "%.2f", amount )
      end
      if( units == "dollars" )
        str = "$#{formatted_amount}"
      elsif( units == "minutes" )
        str = "#{formatted_amount} #{amount == 1 ? 'minute' : 'minutes'}"
      end
      return( str )
    end
end

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
  validates :user_id, :presence => true

  before_validation :update_daily_values

  def full_description
    desc = "#{name}: #{amount_string}/#{period_unit}"
    desc += " for #{workable.name}" if( workable_id )
    return desc
  end

  def amount_complete( opts = {} )
    if( units == "minutes" )
      TicketTime.batch_minutes_worked( applicable_ticket_times( opts ) )
    elsif( units == "dollars" )
      TicketTime.batch_dollars_earned( applicable_ticket_times( opts ) )
    else # to not crash validations without units
      0
    end
  end

  def percent_complete
    fraction = amount_complete / amount
    return( fraction > 1 ? 100 : ( fraction * 100 ).round )
  end

  def applicable_ticket_times( opts = {} )
    case period
    when "Daily"
      start_time = opts[:start_time] || Time.zone.now.beginning_of_day
      end_time = opts[:end_time] || start_time + 1.day
    when "Weekly"
      start_time = opts[:start_time] || Time.zone.now.beginning_of_week
      end_time = opts[:end_time] || start_time + 1.week
    when "Monthly"
      start_time = opts[:start_time] || Time.zone.now.beginning_of_month
      end_time = opts[:end_time] || start_time + 1.month
    when "Yearly"
      start_time = opts[:start_time] || Time.zone.now.beginning_of_year
      end_time = opts[:end_time] || start_time + 1.year
    end
    if( workable_id.nil? )
      ticket_times = TicketTime
    else
      ticket_times = workable.ticket_times
    end
    ticket_times = ticket_times.where( :worker_id => user.id ).where( "started_at >= ? and started_at < ?", start_time, end_time )
  end

  def amount_to_date
    if( period == "Daily" && Time.zone.now.wday != weekday )
      0
    else
      workweek = user.current_workweek
      total_days = workweek.workday_count( :period => period )
      days_to_current = workweek.workday_count( :period => period, :end_time => Time.zone.now )
      total_days > 0 ? amount.to_f / total_days * days_to_current : 0
    end
  end

  def amount_complete_today
    @amount_complete_today ||= amount_complete( :start_time => Time.zone.now.beginning_of_day )
  end

  def update_daily_values
    self.daily_date = Time.zone.now
    self.daily_goal_amount = amount_to_date - amount_complete( :end_time => Time.zone.now.beginning_of_day )
  end

  def highest_priority_ticket
    if( workable && workable.class.name == "Ticket" )
      workable
    else
      user.tickets.includes( :user_roles ).order( :priority ).first
    end
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

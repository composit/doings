class Goal < ActiveRecord::Base
  belongs_to :user
  belongs_to :workable, :polymorphic => true

  WORKABLE_TYPES = ["Client", "Project", "Ticket"]
  PERIOD_OPTIONS = ["Yearly", "Monthly", "Weekly", "Daily"]
  UNIT_OPTIONS = ["minutes", "dollars"]
  WEEKDAY_OPTIONS = { "Sunday" => 0, "Monday" => 1, "Tuesday" => 2, "Wednesday" => 3, "Thursday" => 4, "Friday" => 5, "Saturday" => 6 }

  validates :name, :presence => true
  validates :amount, :presence => true, :numericality => true
  validates :workable_type, :inclusion => { :in => WORKABLE_TYPES }, :allow_blank => true
  validates :period, :presence => true, :inclusion => { :in => PERIOD_OPTIONS }
  validates :units, :presence => true, :inclusion => { :in => UNIT_OPTIONS }
  validates :user_id, :presence => true

  before_validation :update_daily_values, :generate_priorities

  def full_description
    desc = "#{name}: #{amount_string}/#{period_unit}"
    desc += " for #{workable.name}" if( workable_id )
    return desc
  end

  def amount_complete( opts = {} )
    if( units == "minutes" )
      TicketTime.batch_seconds_worked( applicable_ticket_times( opts ) ).to_f / 60
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
    daily_amount = amount_to_date - amount_complete( :end_time => Time.zone.now.beginning_of_day )
    self.daily_goal_amount = ( daily_amount < 0 ? 0 : daily_amount )
  end

  def best_available_ticket
    if( amount_complete_today < daily_goal_amount )
      tickets = user.tickets.where( :closed_at => nil )
      tickets = tickets.where( :id => workable_id ) if( workable_id && workable_type == "Ticket" )
      tickets = tickets.where( :project_id => workable_id ) if( workable_id && workable_type == "Project" )
      tickets = tickets.joins( :project ).where( :projects => { :client_id => workable_id } ) if( workable_id && workable_type == "Client" )
      if( units == "minutes" )
        tickets = tickets.order( :priority )
      elsif( units == "dollars" )
        tickets = tickets.order( :priority ).sort { |x,y| y.billing_rate.marginal_hourly_rate <=> x.billing_rate.marginal_hourly_rate }
      end
      return( tickets.first )
    end
  end

  def self.reprioritize!( priority_array )
    priority_array.each do |goal_id, priority_hash|
      order = priority_hash["new"].to_f
      order = order - 0.5 if( priority_hash["old"] > priority_hash["new"] )
      order = order + 0.5 if( priority_hash["old"] < priority_hash["new"] )
      priority_hash["order"] = order
    end
    priority_array.to_a.sort { |x,y| x[1]["order"] <=> y[1]["order"] }.each_with_index do |goal_array, index|
      goal = Goal.find( goal_array[0] )
      goal.priority = index + 1
      goal.save( :validate => false )
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

    def generate_priorities
      unless( priority )
        goals = user.goals.order( :priority )
        self.priority = ( goals.empty? ? 1 : goals.last.priority.to_i + 1 )
      end
    end
end

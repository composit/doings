class Workweek < ActiveRecord::Base
  belongs_to :worker, :class_name => 'User'

  after_save :update_goals

  def workday_count( opts = {} )
    opts[:current_time] ||= Time.zone.now
    case opts[:period] 
    when "Weekly"
      opts[:start_time] ||= opts[:current_time].beginning_of_week
      opts[:end_time] ||= opts[:current_time].end_of_week
    when "Monthly"
      opts[:start_time] ||= opts[:current_time].beginning_of_month
      opts[:end_time] ||= opts[:current_time].end_of_month
    when "Yearly"
      opts[:start_time] ||= opts[:current_time].beginning_of_year
      opts[:end_time] ||= opts[:current_time].end_of_year
    else # "Daily"
      opts[:start_time] ||= opts[:current_time]
      opts[:end_time] ||= opts[:current_time]
    end
    count_days( opts[:start_time], opts[:end_time], opts[:update_day] )
  end

  def number_of_workdays
    weekdays.length
  end

  private
    def weekdays
      wdays = []
      wdays << 0 if( sunday )
      wdays << 1 if( monday )
      wdays << 2 if( tuesday )
      wdays << 3 if( wednesday )
      wdays << 4 if( thursday )
      wdays << 5 if( friday )
      wdays << 6 if( saturday )
      return( wdays )
    end

    def count_days( start_time, end_time, update_day = nil )
      check_days = ( update_day ? [update_day] : weekdays ) 
      if( start_time.year == end_time.year )
        ( start_time.yday .. end_time.yday ).select { |day| check_days.include?( Date.ordinal( start_time.year, day ).wday ) }.length
      else
        ( start_time.yday .. start_time.end_of_year.yday ).select { |day| check_days.include?( Date.ordinal( start_time.year, day ).wday ) }.length + ( end_time.beginning_of_year.yday .. end_time.yday ).select { |day| check_days.include?( Date.ordinal( end_time.year, day ).wday ) }.length
      end
    end

    def update_goals
      # update goals: previously completed amount
      worker.goals.each { |goal| goal.save! }
    end
end

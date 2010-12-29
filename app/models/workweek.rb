class Workweek < ActiveRecord::Base
  belongs_to :worker, :class_name => 'User'

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
    count_days( opts[:start_time], opts[:end_time] )
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

    def count_days( start_time, end_time )
      if( start_time.year == end_time.year )
        ( start_time.yday .. end_time.yday ).select { |day| weekdays.include?( Date.ordinal( start_time.year, day ).wday ) }.length
      else
        ( start_time.yday .. start_time.end_of_year.yday ).select { |day| weekdays.include?( Date.ordinal( start_time.year, day ).wday ) }.length + ( end_time.beginning_of_year.yday .. end_time.yday ).select { |day| weekdays.include?( Date.ordinal( end_time.year, day ).wday ) }.length
      end
    end
end

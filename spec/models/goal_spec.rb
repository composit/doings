require 'spec_helper'

describe Goal do
  it "should validate with valid attributes" do
    Factory.build( :goal ).should be_valid
  end

  it "should require a name" do
    goal = Factory.build( :goal, :name => nil )
    goal.save

    goal.errors.should eql( :name => ["can't be blank"] )
  end

  it "should require an amount" do
    goal = Factory.build( :goal, :amount => nil )
    goal.save

    goal.errors.should eql( :amount => ["can't be blank", "is not a number"] )
  end

  it "should require a numeric amount" do
    goal = Factory.build( :goal, :amount => "abc" )
    goal.save

    goal.errors.should eql( :amount => ["is not a number"] )
  end

  it "should require a period" do
    goal = Factory.build( :goal, :period => nil )
    goal.save

    goal.errors.should eql( :period => ["can't be blank", "is not included in the list"] )
  end

  it "should require a period from the list" do
    goal = Factory.build( :goal, :period => "abc" )
    goal.save

    goal.errors.should eql( :period => ["is not included in the list"] )
  end

  it "should require units" do
    goal = Factory.build( :goal, :units => nil )
    goal.save

    goal.errors.should eql( :units => ["can't be blank", "is not included in the list"] )
  end

  it "should require units from the list" do
    goal = Factory.build( :goal, :units => "abc" )
    goal.save

    goal.errors.should eql( :units => ["is not included in the list"] )
  end

  it "should allow a blank workable" do
    Factory.build( :goal, :workable => nil ).should be_valid
  end

  it "should require a workable_type from the list if set" do
    goal = Factory.build( :goal, :workable_type => "abc" )
    goal.save

    goal.errors.should eql( :workable_type => ["is not included in the list"] )
  end

  it "should generate a full minutes description for a client-specific goal" do
    client = Factory( :client, :name => "Test client" )
    goal = Factory( :goal, :workable => client, :period => "Yearly", :amount => 3, :name => "Test goal", :units => "minutes" )

    goal.full_description.should eql( "Test goal: 3 minutes/year for Test client" )
  end

  it "should generate a full singularized minutes description for a client-specific goal" do
    client = Factory( :client, :name => "Test client" )
    goal = Factory( :goal, :workable => client, :period => "Yearly", :amount => 1, :name => "Test goal", :units => "minutes" )

    goal.full_description.should eql( "Test goal: 1 minute/year for Test client" )
  end

  it "should generate a full dollars description for a client-specific goal" do
    client = Factory( :client, :name => "Test client" )
    goal = Factory( :goal, :workable => client, :period => "Yearly", :amount => 3.21, :name => "Test goal", :units => "dollars" )

    goal.full_description.should eql( "Test goal: $3.21/year for Test client" )
  end

  it "should find ticket times within the range of a daily goal" do
    user = Factory( :worker )
    goal = Factory( :goal, :user => user, :period => "Daily" )
    good_time_one = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_day, :ended_at => 30.minutes.ago )
    good_time_two = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_day, :ended_at => Time.zone.now.end_of_day )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_day - 1.second, :ended_at => Time.zone.now.beginning_of_day - 1.second )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_day + 1.second, :ended_at => Time.zone.now.end_of_day + 2.seconds )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time_one.id, good_time_two.id] )
  end

  it "should find ticket times within the range of a weekly goal" do
    user = Factory( :worker )
    goal = Factory( :goal, :user => user, :period => "Weekly" )
    good_time_one = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_week, :ended_at => Time.zone.now.beginning_of_week )
    good_time_two = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_week, :ended_at => Time.zone.now.end_of_week )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_week - 1.second, :ended_at => Time.zone.now.beginning_of_week - 1.second )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_week + 1.second, :ended_at => Time.zone.now.end_of_week + 1.second )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time_one.id, good_time_two.id] )
  end

  it "should find ticket times within the range of a monthly goal" do
    user = Factory( :worker )
    goal = Factory( :goal, :user => user, :period => "Monthly" )
    good_time_one = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_month, :ended_at => Time.zone.now.beginning_of_month + 1.hour )
    good_time_two = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_month, :ended_at => Time.zone.now.end_of_month )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_month - 1.second, :ended_at => Time.zone.now.beginning_of_month - 1.second )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_month + 1.second, :ended_at => Time.zone.now.end_of_month + 2.seconds )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time_one.id, good_time_two.id] )
  end

  it "should find ticket times within the range of a yearly goal" do
    user = Factory( :worker )
    goal = Factory( :goal, :user => user, :period => "Yearly" )
    good_time_one = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_year, :ended_at => Time.zone.now.beginning_of_year + 1.hour )
    good_time_two = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_year, :ended_at => Time.zone.now.end_of_year )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_year - 1.second, :ended_at => Time.zone.now.beginning_of_year - 1.second )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_year + 1.second, :ended_at => Time.zone.now.end_of_year + 2.seconds )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time_one.id, good_time_two.id] )
  end

  it "should find ticket times within the range of a client-specific goal" do
    user = Factory( :worker )
    client = Factory( :client )
    ticket = Factory( :ticket, :project => Factory( :project, :client => client ) )
    goal = Factory( :goal, :user => user, :workable => client )
    good_time = Factory( :ticket_time, :worker => user, :ticket => ticket )
    Factory( :ticket_time, :worker => user )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time.id] )
  end

  it "should find ticket times within the range of a project-specific goal" do
    user = Factory( :worker )
    project = Factory( :project )
    ticket = Factory( :ticket, :project => project )
    goal = Factory( :goal, :user => user, :workable => project )
    good_time = Factory( :ticket_time, :worker => user, :ticket => ticket )
    Factory( :ticket_time, :worker => user )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time.id] )
  end

  it "should find ticket times within the range of a ticket-specific goal" do
    user = Factory( :worker )
    ticket = Factory( :ticket )
    goal = Factory( :goal, :user => user, :workable => ticket )
    good_time = Factory( :ticket_time, :worker => user, :ticket => ticket )
    Factory( :ticket_time, :worker => user )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time.id] )
  end

  it "should not include times worked by other workers" do
    user = Factory( :user )
    goal = Factory( :goal, :user => user, :period => "Daily" )
    good_time = Factory( :ticket_time, :worker => user )
    Factory( :ticket_time )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time.id] )
  end

  it "should calculate amount completion for a minute-based goal" do
    user = Factory( :worker )
    goal = Factory( :goal, :user => user, :units => "minutes", :amount => 60 )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now, :ended_at => 30.minutes.since )

    goal.amount_complete.should eql( 30.0 )
  end

  it "should calculate percent completion for a minute-based goal" do
    user = Factory( :worker )
    goal = Factory( :goal, :user => user, :units => "minutes", :amount => 60 )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now, :ended_at => 30.minutes.since )

    goal.percent_complete.should eql( 50 )
  end

  it "should calculate amount completion for a dollar-based goal" do
    user = Factory( :worker )
    goal = Factory( :goal, :user => user, :units => "dollars", :amount => 100 )
    ticket = Factory( :ticket, :billing_rate => Factory( :billing_rate, :units => "hour", :dollars => 100 ) )
    Factory( :ticket_time, :ticket => ticket, :worker => user, :started_at => Time.zone.now, :ended_at => 30.minutes.since )

    goal.amount_complete.should eql( 50.0 )
  end

  it "should calculate percent completion for a dollar-based goal" do
    user = Factory( :worker )
    goal = Factory( :goal, :user => user, :units => "dollars", :amount => 100 )
    ticket = Factory( :ticket, :billing_rate => Factory( :billing_rate, :units => "hour", :dollars => 100 ) )
    Factory( :ticket_time, :ticket => ticket, :worker => user, :started_at => Time.zone.now, :ended_at => 30.minutes.since )

    goal.percent_complete.should eql( 50 )
  end

  it "should return 100% completion for goals that are greater than 100%" do
    user = Factory( :worker )
    goal = Factory( :goal, :user => user, :units => "minutes", :amount => 60 )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now, :ended_at => 1.day.since )

    goal.percent_complete.should eql( 100 )
  end

  describe "with a varied set of goals" do
    before( :each ) do
      Timecop.freeze( Time.parse( "2010-12-29" ) ) #wednesday
      @user = Factory( :worker )
      Factory( :workweek, :worker => @user, :sunday => false, :monday => true, :tuesday => true, :wednesday => true, :thursday => true, :friday => true, :saturday => false )
      @daily_monday = Factory( :goal, :user => @user, :units => "minutes", :amount => 10, :period => "Daily", :weekday => 1 )
      @daily_wednesday = Factory( :goal, :user => @user, :units => "minutes", :amount => 20, :period => "Daily", :weekday => 3 )
      @weekly = Factory( :goal, :user => @user, :units => "minutes", :amount => 30, :period => "Weekly" )
      @monthly = Factory( :goal, :user => @user, :units => "minutes", :amount => 40, :period => "Monthly" )
      @yearly = Factory( :goal, :user => @user, :units => "minutes", :amount => 50, :period => "Yearly" )
    end

    after( :each ) do
      Timecop.return
    end

    it "should calculate a zero amount to be complete by the end of the day for daily tasks on other days" do
      @daily_monday.amount_to_date.should eql( 0 )
    end

    it "should calculate the amount to be complete by the end of the day for daily tasks" do
      @daily_wednesday.amount_to_date.should eql( 20.0 )
    end

    it "should calculate the amount to be complete by the end of the day for weekly tasks" do
      @weekly.amount_to_date.should eql( 18.0 )
    end

    it "should calculate the amount to be complete by the end of the day for monthly tasks" do
      @monthly.amount_to_date.round.should eql( 37 )
    end

    it "should calculate the amount to be complete by the end of the day for yearly tasks" do
      ( ( @yearly.amount_to_date * 100 ).round.to_f / 100 ).should eql( 49.62 )
    end
  end

  it "should calculate amount completion up to a specific time" do
    user = Factory( :worker )
    goal = Factory( :goal, :user => user, :units => "minutes", :amount => 100, :period => "Yearly" )
    ticket = Factory( :ticket, :billing_rate => Factory( :billing_rate, :units => "hour", :dollars => 100 ) )
    Factory( :ticket_time, :ticket => ticket, :worker => user, :started_at => 1.day.ago, :ended_at => 23.hours.ago )
    Factory( :ticket_time, :ticket => ticket, :worker => user, :started_at => 30.minutes.ago, :ended_at => Time.zone.now )

    goal.amount_complete( :end_time => Time.zone.now.beginning_of_day ).should eql( 60.0 )
  end

  it "should take into account projects with monthly rates that are over their rate" do
    user = Factory( :worker )
    goal = Factory( :goal, :user => user, :units => "dollars", :amount => 100, :period => "Yearly" )
    ticket = Factory( :ticket, :billing_rate => Factory( :billing_rate, :units => "month", :dollars => 50, :hourly_rate_for_calculations => 80 ) )
    Factory( :ticket_time, :ticket => ticket, :worker => user, :started_at => 1.day.ago, :ended_at => 23.hours.ago )

    goal.amount_complete( :end_time => Time.zone.now ).should eql( 50.0 )
  end

  it "should calculate amount completion after a specific time" do
    user = Factory( :worker )
    goal = Factory( :goal, :user => user, :units => "minutes", :amount => 100, :period => "Yearly" )
    ticket = Factory( :ticket, :billing_rate => Factory( :billing_rate, :units => "hour", :dollars => 100 ) )
    Factory( :ticket_time, :ticket => ticket, :worker => user, :started_at => 1.day.ago, :ended_at => 23.hours.ago )
    Factory( :ticket_time, :ticket => ticket, :worker => user, :started_at => 30.minutes.ago, :ended_at => Time.zone.now )

    goal.amount_complete( :start_time => Time.zone.now.beginning_of_day ).should eql( 30.0 )
  end

  describe "with a user with a workweek, a goal and time worked" do
    before( :each ) do
      Timecop.freeze( Time.parse( "2010-12-29 12:00:00" ) ) #wednesday
      @user = Factory( :worker )
      Factory( :workweek, :worker => @user, :monday => true, :friday => true )
      @goal = Factory( :goal, :period => "Weekly", :user => @user, :units => "minutes", :amount => 240 )
      Factory( :ticket_time, :worker => @user, :started_at => 1.day.ago, :ended_at => 23.hours.ago )
      Factory( :ticket_time, :worker => @user, :started_at => 30.minutes.ago, :ended_at => Time.zone.now )
      @goal.save!
    end

    after( :each ) do
      Timecop.return
    end

    it "should set the daily date to today" do
      @goal.reload.daily_date.strftime( "%Y-%m-%d" ).should eql( "2010-12-29" )
    end

    it "should return the amount completed during that day" do
      @goal.amount_complete_today.should eql( 30.0 )
    end

    it "should set the daily amount to be completed during that day" do
      @goal.reload.daily_goal_amount.should eql( 60.0 ) # 240/2 - 60
    end

    it "should set negative daily goal amounts to zero" do
      Factory( :ticket_time, :worker => @user, :started_at => 2.days.ago, :ended_at => 1.day.ago )
      @goal.reload.daily_goal_amount.should eql( 0.0 )
    end
  end

  it "should return nothing as the best available ticket if there are no tickets available" do
    user = Factory( :user )
    Factory( :workweek, :worker => user, :monday => true )
    Factory( :goal, :user => user ).best_available_ticket.should be_nil
  end

  describe "with available tickets" do
    before( :each ) do
      @user = Factory( :user )
      Factory( :workweek, :worker => @user, :monday => true )
      @last_ticket = Factory( :ticket )
      @first_ticket = Factory( :ticket )
      @middle_ticket = Factory( :ticket )
      Factory( :user_role, :user => @user, :manageable => @last_ticket, :priority => 3, :worker => true )
      Factory( :user_role, :user => @user, :manageable => @first_ticket, :priority => 1, :worker => true )
      Factory( :user_role, :user => @user, :manageable => @middle_ticket, :priority => 2, :worker => true )
    end

    it "should favor higher priority tickets for time-based goals" do
      goal = Factory( :goal, :user => @user, :units => "minutes", :amount => 1 )

      goal.best_available_ticket.should eql( @first_ticket )
    end

    it "should favor tickets with higher rates for dollar-based goals" do
      @last_ticket.billing_rate.update_attributes!( :dollars => 80, :units => "hour" )
      @first_ticket.billing_rate.update_attributes!( :dollars => 80, :units => "hour" )
      @middle_ticket.billing_rate.update_attributes!( :dollars => 100, :units => "hour" )
      goal = Factory( :goal, :user => @user, :units => "dollars", :amount => 1 )

      goal.best_available_ticket.should eql( @middle_ticket )
    end

    it "should consider hourly_rates_for_calculations, not dollars when figuring dollar-based goals" do
      @last_ticket.billing_rate.update_attributes!( :dollars => 80, :units => "total", :hourly_rate_for_calculations => 1 )
      @first_ticket.billing_rate.update_attributes!( :dollars => 60, :units => "total", :hourly_rate_for_calculations => 10 )
      @middle_ticket.billing_rate.update_attributes!( :dollars => 100, :units => "total", :hourly_rate_for_calculations => 5 )
      goal = Factory( :goal, :user => @user, :units => "dollars", :amount => 1 )

      goal.best_available_ticket.should eql( @first_ticket )
    end

    it "should order tickets by priority for dollar-based goals where rates are the same" do
      @last_ticket.billing_rate.update_attributes!( :dollars => 100, :units => "hour" )
      @first_ticket.billing_rate.update_attributes!( :dollars => 100, :units => "hour" )
      @middle_ticket.billing_rate.update_attributes!( :dollars => 100, :units => "hour" )
      goal = Factory( :goal, :user => @user, :units => "dollars", :amount => 1 )

      goal.best_available_ticket.should eql( @first_ticket )
    end

    it "should ignore tickets not associated with a ticket when returning the best available ticket for a ticket goal" do
      goal = Factory( :goal, :user => @user, :workable => @middle_ticket, :amount => 1 )
      goal.best_available_ticket.should eql( @middle_ticket )
    end

    it "should ignore tickets not associated with a project when returning the best available ticket for a project goal" do
      project = Factory( :project )
      @middle_ticket.update_attributes!( :project => project )
      goal = Factory( :goal, :user => @user, :workable => project, :amount => 1 )

      goal.best_available_ticket.should eql( @middle_ticket )
    end

    it "should ignore tickets not associated with a client when returning the best available ticket for a client goal" do
      client = Factory( :client )
      project = Factory( :project, :client => client )
      @middle_ticket.update_attributes!( :project => project )
      goal = Factory( :goal, :user => @user, :workable => client, :amount => 1 )

      goal.best_available_ticket.should eql( @middle_ticket )
    end

    it "should ignore closed tickets" do
      @first_ticket.update_attributes!( :closed_at => Time.zone.now )
      goal = Factory( :goal, :user => @user, :units => "minutes", :amount => 1 )

      goal.best_available_ticket.should eql( @middle_ticket )
    end

    it "should ignore tickets whose calculated work is greater than their monthly/total rate for a dollar-based goal" do
      @last_ticket.billing_rate.update_attributes!( :dollars => 80, :units => "total", :hourly_rate_for_calculations => 1 )
      @first_ticket.billing_rate.update_attributes!( :dollars => 10, :units => "total", :hourly_rate_for_calculations => 10 )
      @middle_ticket.billing_rate.update_attributes!( :dollars => 100, :units => "total", :hourly_rate_for_calculations => 5 )
      Factory( :ticket_time, :ticket => @first_ticket, :worker => @user, :started_at => 1.day.ago, :ended_at => 23.hours.ago )
      goal = Factory( :goal, :user => @user, :units => "dollars", :amount => 1000 )

      goal.best_available_ticket.should eql( @middle_ticket )
    end

    it "should return nothing for a finished goal" do
      goal = Factory( :goal, :user => @user, :units => "minutes", :amount => 30 )
      Factory( :ticket_time, :worker => @user, :started_at => 1.hour.ago, :ended_at => Time.zone.now )

      goal.best_available_ticket.should be_nil
    end
  end

  it "should return zero as the amount to date if there are no days in the user's workweek" do
    user = Factory( :user )
    Factory( :workweek, :worker => user )
    goal = Factory.build( :goal, :user => user )
    goal.amount_to_date.should eql( 0 )
  end

  describe "when reprioritizing" do
    before( :each ) do
      @goal_one = Factory( :goal, :id => 1, :priority => 1 )
      @goal_two = Factory( :goal, :id => 2, :priority => 2 )
      @goal_three = Factory( :goal, :id => 3, :priority => 3 )
    end

    it "should reprioritize goals" do
      Goal.reprioritize!( "1" => { "old" => "1", "new" => "2" }, "2" => { "old" => "2", "new" => "1" }, "3" => { "old" => "3", "new" => "3" } )
      @goal_one.reload.priority.should eql( 2 )
      @goal_two.reload.priority.should eql( 1 )
      @goal_three.reload.priority.should eql( 3 )
    end

    it "should favor the values of changing priorities if they overlap and the changing priorities are decreasing" do
      Goal.reprioritize!( "1" => { "old" => "1", "new" => "1" }, "2" => { "old" => "2", "new" => "2" }, "3" => { "old" => "3", "new" => "2" } )
      @goal_one.reload.priority.should eql( 1 )
      @goal_two.reload.priority.should eql( 3 )
      @goal_three.reload.priority.should eql( 2 )
    end

    it "should favor the values of changing priorities if they overlap and the changing priorities are increasing" do
      Goal.reprioritize!( "1" => { "old" => "1", "new" => "2" }, "2" => { "old" => "2", "new" => "2" }, "3" => { "old" => "3", "new" => "3" } )
      @goal_one.reload.priority.should eql( 2 )
      @goal_two.reload.priority.should eql( 1 )
      @goal_three.reload.priority.should eql( 3 )
    end

    it "should fill in gaps in priority" do
      Goal.reprioritize!( "1" => { "old" => "1", "new" => "10" }, "2" => { "old" => "2", "new" => "100" }, "3" => { "old" => "3", "new" => "5" } )
      @goal_one.reload.priority.should eql( 2 )
      @goal_two.reload.priority.should eql( 3 )
      @goal_three.reload.priority.should eql( 1 )
    end
  end

  describe "when working with priorities" do
    before( :each ) do
      @user = Factory( :worker )
      Factory( :goal, :user => @user, :priority => 1 )
      Factory( :goal, :user => @user, :priority => 2 )
      Factory( :goal, :user => @user, :priority => 3 )
      Factory( :goal, :priority => 10 )
    end

    it "should assign priority-less (new) goals lowest priority" do
      goal = Factory( :goal, :user => @user )
      goal.reload.priority.should eql( 4 )
    end

    it "should not overwrite priorities if they exist" do
      goal = Factory( :goal, :user => @user, :priority => 10 )
      goal.reload.priority.should eql( 10 )
    end

    it "should automatically set the first created goal's priority to 1" do
      user = Factory( :worker )
      goal = Factory( :goal, :user => user )
      goal.reload.priority.should eql( 1 )
    end
  end
end

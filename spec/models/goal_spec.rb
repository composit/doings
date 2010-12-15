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
    user = Factory( :user )
    goal = Factory( :goal, :user => user, :period => "Daily" )
    good_time_one = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_day, :ended_at => 30.minutes.ago )
    good_time_two = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_day, :ended_at => 1.day.since )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_day - 1.second, :ended_at => 30.minutes.ago )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_day + 1.second, :ended_at => 1.day.since )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time_one.id, good_time_two.id] )
  end

  it "should find ticket times within the range of a weekly goal" do
    user = Factory( :user )
    goal = Factory( :goal, :user => user, :period => "Weekly" )
    good_time_one = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_week, :ended_at => 30.minutes.ago )
    good_time_two = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_week, :ended_at => 1.week.since )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_week - 1.second, :ended_at => 30.minutes.ago )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_week + 1.second, :ended_at => 1.week.since )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time_one.id, good_time_two.id] )
  end

  it "should find ticket times within the range of a monthly goal" do
    user = Factory( :user )
    goal = Factory( :goal, :user => user, :period => "Monthly" )
    good_time_one = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_month, :ended_at => 30.minutes.ago )
    good_time_two = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_month, :ended_at => 1.month.since )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_month - 1.second, :ended_at => 30.minutes.ago )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_month + 1.second, :ended_at => 1.month.since )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time_one.id, good_time_two.id] )
  end

  it "should find ticket times within the range of a yearly goal" do
    user = Factory( :user )
    goal = Factory( :goal, :user => user, :period => "Yearly" )
    good_time_one = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_year, :ended_at => 30.minutes.ago )
    good_time_two = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_year, :ended_at => 1.year.since )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.beginning_of_year - 1.second, :ended_at => 30.minutes.ago )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now.end_of_year + 1.second, :ended_at => 1.year.since )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time_one.id, good_time_two.id] )
  end

  it "should find ticket times within the range of a client-specific goal" do
    user = Factory( :user )
    client = Factory( :client )
    ticket = Factory( :ticket, :project => Factory( :project, :client => client ) )
    goal = Factory( :goal, :user => user, :workable => client )
    good_time = Factory( :ticket_time, :worker => user, :ticket => ticket )
    Factory( :ticket_time, :worker => user )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time.id] )
  end

  it "should find ticket times within the range of a project-specific goal" do
    user = Factory( :user )
    project = Factory( :project )
    ticket = Factory( :ticket, :project => project )
    goal = Factory( :goal, :user => user, :workable => project )
    good_time = Factory( :ticket_time, :worker => user, :ticket => ticket )
    Factory( :ticket_time, :worker => user )

    goal.applicable_ticket_times.collect { |time| time.id }.should eql( [good_time.id] )
  end

  it "should find ticket times within the range of a ticket-specific goal" do
    user = Factory( :user )
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

  it "should calculate completion for a minute-based goal" do
    user = Factory( :worker )
    goal = Factory( :goal, :user => user, :units => "minutes", :amount => 60 )
    Factory( :ticket_time, :worker => user, :started_at => Time.zone.now, :ended_at => 30.minutes.since )

    goal.percent_complete.should eql( 50 )
  end

  it "should calculate completion for a dollar-based goal" do
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

  pending "should allow the week to be defined"
  pending "should allow daily tasks to have the day specified"
  pending "should return the percent to be complete by the end of the day for daily tasks"
  pending "should return the percent to be complete by the end of the day for weekly tasks"
  pending "should return the percent to be complete by the end of the day for monthly tasks"
  pending "should return the percent to be complete by the end of the day for yearly tasks"
end

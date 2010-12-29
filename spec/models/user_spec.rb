require 'spec_helper'

describe User do
  it "should validate with valid attributes" do
    Factory.build( :user ).should be_valid
  end

  it "should require an email" do
    user = Factory.build( :user, :email => "" )
    user.save

    user.errors.should eql( :email => ["can't be blank"] )
  end

  it "should require a unique email" do
    Factory( :user, :email => "test@example.com" )
    user = Factory.build( :user, :email => "test@example.com" )
    user.save

    user.errors.should eql( :email => ["has already been taken"] )
  end

  it "should require a username" do
    user = Factory.build( :user, :username => "" )
    user.save

    user.errors.should eql( :username => ["can't be blank"] )
  end

  it "should require a unique username" do
    Factory( :user, :username => "abc" )
    user = Factory.build( :user, :username => "abc" )
    user.save

    user.errors.should eql( :username => ["has already been taken"] )
  end

  it "should require a time zone" do
    user = Factory.build( :user, :time_zone => "" )
    user.save

    user.errors.should eql( :time_zone => ["can't be blank"] )
  end

  it "should not be identified as a worker if it doesn't have anything it's working on" do
    user = Factory( :user )
    user.is_worker?.should be_false
  end

  it "should be identified as a worker if it has anything it's working on" do
    user = Factory( :user )
    user.user_roles << Factory( :user_role, :manageable => Factory( :client ), :worker => true )
    user.is_worker?.should be_true
  end

  it "should return the current workweek" do
    user = Factory( :worker )
    old_workweek = Factory( :workweek, :worker => user, :created_at => Time.zone.now - 1.week )
    current_workweek = Factory( :workweek, :worker => user, :created_at => Time.zone.now )
    future_workweek = Factory( :workweek, :worker => user, :created_at => Time.zone.now + 1.day )
    user.current_workweek.should eql( current_workweek )
  end

  describe "when retrieving daily goals" do
    before( :each ) do
      Timecop.travel( Time.parse( "2010-12-28 12:00:00" ) ) #tuesday
      @user = Factory( :worker )
      other_user = Factory( :worker )
      @goal = Factory( :goal, :user => @user, :period => "Weekly", :units => "minutes", :amount => 200 )
      @other_goal = Factory.build( :goal, :user => other_user )
      @other_goal.save( :validate => false )
      @user.daily_goals!
      @goal_updated_at = @goal.reload.updated_at
    end

    after( :each ) do
      Timecop.return
    end

    it "should calculate daily amounts for all goals if they have not been calculated that day" do
      @goal.reload.daily_goal_amount.should eql( 80.0 )
    end

    it "should not calculate daily amounts for goals for other users" do
      @other_goal.reload.daily_date.should be_nil
    end

    it "should not recalculate daily amounts for goals if they have already been calculated" do
      sleep( 1 )
      @user.daily_goals!
      @goal.reload.updated_at.should eql( @goal_updated_at )
    end

    it "should recalculate daily amounts for goals that have been updated, even if they have been calculated that day" do
      @goal.update_attributes!( :amount => 400 )
      @goal.reload.daily_goal_amount.should eql( 160.0 )
    end

    it "should recalculate daily amounts for goals that have had previous time added, even if they have been calculated for that day" do
      Factory( :ticket_time, :worker => @user, :started_at => 1.day.ago, :ended_at => 23.hours.ago )
      @goal.reload.daily_goal_amount.should eql( 20.0 )
    end

    it "should not recalculate daily amounts for that have had current time added" do
      sleep( 1 )
      Factory( :ticket_time, :worker => @user, :started_at => 1.hour.ago, :ended_at => Time.zone.now )
      @goal.reload.updated_at.should eql( @goal_updated_at )
    end

    it "should not recalculate daily amounts for goals for other users that have had previous time added, even if they have been calculated for that day" do
      sleep( 1 )
      Factory( :ticket_time, :worker => Factory( :worker ), :started_at => 1.day.ago, :ended_at => 23.hours.ago )
      @goal.reload.updated_at.should eql( @goal_updated_at )
    end
  end


  describe "with goals and time worked" do
    before( :each ) do
      Timecop.travel( Time.parse( "2010-12-29 12:00:00" ) ) #wednesday
      @user = Factory( :user )
      Factory( :workweek, :worker => @user, :monday => true, :friday => true )
      @ticket = Factory( :ticket )
      @ticket.billing_rate.update_attributes!( :units => "hour", :dollars => 100 )
      Factory( :ticket_time, :ticket => @ticket, :worker => @user, :started_at => 1.day.ago, :ended_at => 23.hours.ago )
      Factory( :ticket_time, :ticket => @ticket, :worker => @user, :started_at => 40.minutes.ago, :ended_at => Time.zone.now )
    end

    after( :each ) do
      Timecop.return
    end

    it "should weight goals by unit within types for the daily percentage complete" do
      Factory( :goal, :user => @user, :period => "Weekly", :workable => @ticket, :units => "minutes", :amount => 240 )
      Factory( :goal, :user => @user, :period => "Weekly", :units => "minutes", :amount => 400 )
      # daily goal amounts = ( 120 - 60 ) + ( 200 - 60 ) = 200
      # daily amounts complete = 40 + 40 = 80
      # daily percentage completed = 80/200 = .4
      @user.daily_percentage_complete.should eql( 40 )
    end

    it "should use time-based goals as 100% of goals if there are no dollar-based goals" do
      Factory( :goal, :user => @user, :period => "Weekly", :units => "minutes", :amount => 400 )
      # daily goal amounts = 200 - 60 = 140
      # daily amounts complete = 40
      # daily percentage completed = 40/140 = .2857
      @user.daily_percentage_complete.should eql( 29 )
    end

    it "should use dollar-based goals as 100% of goals if there are no time-based goals" do
      Factory( :goal, :user => @user, :period => "Weekly", :units => "dollars", :amount => 400 )
      # daily goal amounts = 200 - 100 = 100
      # daily amounts complete = 66.6666 
      # daily percentage completed = 66.6666/100 = .6666
      @user.daily_percentage_complete.should eql( 67 )
    end

    it "should split the daily complete percentage evenly between time-based and dollar-based" do
      Factory( :goal, :user => @user, :period => "Weekly", :units => "minutes", :amount => 400 )
      Factory( :goal, :user => @user, :period => "Weekly", :units => "dollars", :amount => 400 )
      # daily minutes percentage complete = .2857
      # daily dollars percentage complete = .6666
      # daily percentage completed = ( .2857 + .6666 ) = .4762
      @user.daily_percentage_complete.should eql( 48 )
    end

    it "should not let one goal with greater than 100% completion contribute more than 100% to total goal percentage" do
      Factory( :goal, :user => @user, :period => "Weekly", :workable => @ticket, :units => "minutes", :amount => 120 )
      Factory( :goal, :user => @user, :period => "Weekly", :units => "minutes", :amount => 400 )
      # daily goal amounts = ( 60 - 60 ) + ( 200 - 60 ) = 140
      # daily amounts complete = 0 + 40 = 40
      # daily percentage completed = 40/140 = .2857
      @user.daily_percentage_complete.should eql( 29 )
    end
  end
end

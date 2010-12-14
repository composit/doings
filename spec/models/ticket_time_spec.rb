require 'spec_helper'

describe TicketTime do
  it "should validate with valid attributes" do
    Factory( :ticket_time ).should be_valid
  end

  it "should require a worker" do
    ticket_time = Factory.build( :ticket_time, :worker_id => nil )
    ticket_time.save

    ticket_time.errors.should eql( :worker_id => ["can't be blank"] )
  end

  it "should require a ticket" do
    ticket_time = Factory.build( :ticket_time, :ticket_id => nil )
    ticket_time.save

    ticket_time.errors.should eql( :ticket_id => ["can't be blank"] )
  end

  it "should default the start time to the current time if it is nil" do
    ticket_time = Factory.build( :ticket_time, :started_at => nil )
    Timecop.freeze( Time.parse( "2001-02-03 04:05:06" ) ) do
      ticket_time.save!
    end

    ticket_time.started_at.should eql( Time.parse( "2001-02-03 04:05:06" ) )
  end

  it "should allow the entered start time if it exists" do
    ticket_time = Factory( :ticket_time, :started_at => "2001-02-03 04:05:06" )

    ticket_time.started_at.should eql( Time.parse( "2001-02-03 04:05:06" ) )
  end

  it "should require that the end time is later than the start time" do
    ticket_time = Factory.build( :ticket_time, :started_at => Time.now, :ended_at => Time.now - 1.hour )
    ticket_time.save

    ticket_time.errors.should eql( :ended_at => ["must be later than started at"] )
  end

  it "should set the end time to the current time if 'stop now' is set" do
    ticket_time = Factory( :ticket_time, :started_at => "2001-01-01 01:01:01" )
    Timecop.freeze( Time.parse( "2001-02-03 04:05:06" ) ) do
      ticket_time.update_attributes( :stop_now => "1" )
    end

    ticket_time.ended_at.should eql( Time.parse( "2001-02-03 04:05:06" ) )
  end

  it "should close open ticket times for that worker when opening a new one" do
    user = Factory( :user )
    ticket_time = Factory( :ticket_time, :worker => user, :started_at => "2001-01-01 01:01:01" )
    Timecop.freeze( Time.parse( "2001-02-03 04:05:06" ) ) do
      Factory( :ticket_time, :worker => user )
    end

    ticket_time.reload.ended_at.should eql( Time.parse( "2001-02-03 04:05:06" ) )
  end

  it "should not close open ticket times for other workers when opening a new one" do
    user = Factory( :user )
    other = Factory( :user )
    ticket_time = Factory( :ticket_time, :worker => other, :started_at => "2001-01-01 01:01:01" )
    Timecop.freeze( Time.parse( "2001-02-03 04:05:06" ) ) do
      Factory( :ticket_time, :worker => user )
    end

    ticket_time.reload.ended_at.should be_nil
  end

  it "should not close open ticket times if the ticket time being created is not open" do
    user = Factory( :user )
    ticket_time = Factory( :ticket_time, :worker => user, :started_at => "2001-01-01 01:01:01" )
    Timecop.freeze( Time.parse( "2001-02-03 04:05:06" ) ) do
      Factory( :ticket_time, :worker => user, :ended_at => Time.zone.now )
    end

    ticket_time.reload.ended_at.should be_nil
  end

  it "should not validate if there is an open ticket time with a date in the future when trying to open a new ticket time" do
    user = Factory( :user )
    ticket_time = Factory( :ticket_time, :worker => user, :started_at => Time.zone.now + 1.day )
    new_ticket_time = Factory.build( :ticket_time, :worker => user )
    new_ticket_time.save

    new_ticket_time.errors.should eql( :worker => ["has a currently open ticket time with a future start date. Please close it before opening a new ticket."] )
  end

  it "should calculate minutes worked for a batch of ticket times" do
    ticket_time_one = Factory( :ticket_time, :started_at => 30.minutes.ago, :ended_at => 20.minutes.ago )
    ticket_time_two = Factory( :ticket_time, :started_at => 10.minutes.ago, :ended_at => 5.minutes.ago )

    TicketTime.batch_minutes_worked( [ticket_time_one, ticket_time_two] ).round.should eql( 15 )
  end

  it "should calculate minutes worked for a batch of ticket times including an open ticket time" do
    ticket_time_one = Factory( :ticket_time, :started_at => 30.minutes.ago, :ended_at => 20.minutes.ago )
    ticket_time_two = Factory( :ticket_time, :started_at => 10.minutes.ago )

    TicketTime.batch_minutes_worked( [ticket_time_one, ticket_time_two] ).round.should eql( 20 )
  end

  it "should calculate dollars earned for a batch of ticket times with hourly rates" do
    ticket_one = Factory( :ticket, :billing_rate => Factory( :billing_rate, :dollars => 10, :units => "hour" ) )
    ticket_two = Factory( :ticket, :billing_rate => Factory( :billing_rate, :dollars => 20, :units => "hour" ) )

    ticket_time_one = Factory( :ticket_time, :ticket => ticket_one, :started_at => 30.minutes.ago, :ended_at => 20.minutes.ago )
    ticket_time_two = Factory( :ticket_time, :ticket => ticket_two, :started_at => 10.minutes.ago, :ended_at => 5.minutes.ago )

    sprintf( "%.2f", TicketTime.batch_dollars_earned( [ticket_time_one, ticket_time_two] ) ).should eql( "3.33" )
  end
end

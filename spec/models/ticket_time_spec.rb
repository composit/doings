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

    new_ticket_time.errors.should eql( :worker => ["has a currently open ticket time with a future start date.  Please close it before opening a new ticket"] )
  end
end

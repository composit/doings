require 'spec_helper'

describe TicketTime do
  it "should validate with valid attributes" do
    Factory( :ticket_time ).should be_valid
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
end

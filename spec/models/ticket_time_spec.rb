require 'spec_helper'

describe TicketTime do
  it "should validate with valid attributes" do
    Factory( :ticket_time ).should be_valid
  end

  it "should require a start time" do
    ticket_time = Factory.build( :ticket_time, :started_at => nil )
    ticket_time.save

    ticket_time.errors.should eql( :started_at => ["can't be blank"] )
  end

  it "should require that the end time is later than the start time" do
    ticket_time = Factory.build( :ticket_time, :started_at => Time.now, :ended_at => Time.now - 1.hour )
    ticket_time.save

    ticket_time.errors.should eql( :ended_at => ["must be later than started at"] )
  end
end

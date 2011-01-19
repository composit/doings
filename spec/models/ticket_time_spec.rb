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
    Timecop.freeze( Time.parse( "2001-01-01 02:03:04" ) ) do
      ticket_time.update_attributes( :stop_now => "1" )
    end

    ticket_time.ended_at.should eql( Time.parse( "2001-01-01 02:03:04" ) )
  end

  it "should close open ticket times for that worker when opening a new one" do
    user = Factory( :user )
    ticket_time = Factory( :ticket_time, :worker => user, :started_at => "2001-01-01 01:01:01" )
    Timecop.freeze( Time.parse( "2001-01-01 02:03:04" ) ) do
      Factory( :ticket_time, :worker => user )
    end

    ticket_time.reload.ended_at.should eql( Time.parse( "2001-01-01 02:03:04" ) )
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

    TicketTime.batch_seconds_worked( [ticket_time_one, ticket_time_two] ).round.should eql( 900 )
  end

  it "should calculate minutes worked for a batch of ticket times including an open ticket time" do
    ticket_time_one = Factory( :ticket_time, :started_at => 30.minutes.ago, :ended_at => 20.minutes.ago )
    ticket_time_two = Factory( :ticket_time, :started_at => 10.minutes.ago )

    TicketTime.batch_seconds_worked( [ticket_time_one, ticket_time_two] ).round.should eql( 1200 )
  end

  it "should calculate dollars earned for a batch of ticket times with hourly rates" do
    ticket_one = Factory( :ticket, :billing_rate => Factory( :billing_rate, :dollars => 10, :units => "hour" ) )
    ticket_two = Factory( :ticket, :billing_rate => Factory( :billing_rate, :dollars => 20, :units => "hour" ) )

    ticket_time_one = Factory( :ticket_time, :ticket => ticket_one, :started_at => 30.minutes.ago, :ended_at => 20.minutes.ago )
    ticket_time_two = Factory( :ticket_time, :ticket => ticket_two, :started_at => 10.minutes.ago, :ended_at => 5.minutes.ago )

    sprintf( "%.2f", TicketTime.batch_dollars_earned( [ticket_time_one, ticket_time_two] ) ).should eql( "3.33" )
  end

  it "should calculate dollars earned for a batch of ticket times with monthly and total rates" do
    ticket_one = Factory( :ticket, :billing_rate => Factory( :billing_rate, :dollars => 1000, :units => "month", :hourly_rate_for_calculations => 60, :billable => Factory( :client ) ) )
    ticket_two = Factory( :ticket, :billing_rate => Factory( :billing_rate, :dollars => 500, :units => "total", :hourly_rate_for_calculations => 80, :billable => Factory( :client ) ) )

    ticket_time_one = Factory( :ticket_time, :ticket => ticket_one, :started_at => 30.minutes.ago, :ended_at => Time.zone.now )
    ticket_time_two = Factory( :ticket_time, :ticket => ticket_two, :started_at => 2.hours.ago, :ended_at => 1.hour.ago )

    sprintf( "%.2f", TicketTime.batch_dollars_earned( [ticket_time_one, ticket_time_two] ) ).should eql( "110.00" ) # .5 * 60 + 1 * 80
  end

  describe "that wraps multiple days" do
    before( :each ) do
      @ticket_time = Factory( :ticket_time, :started_at => "2010-12-28 23:00:00", :ended_at => "2010-12-30 01:00:00" )
    end

    it "should not alter the start time for that ticket" do
      @ticket_time.reload.started_at.should eql( Time.parse( "2010-12-28 23:00:00" ) )
    end

    it "should end that ticket time a second before midnight" do
      @ticket_time.reload.ended_at.should eql( Time.parse( "2010-12-28 23:59:59" ) )
    end

    it "should create one ticket time for each day" do
      TicketTime.count.should eql( 3 )
    end

    describe "with automatically created ticket times" do
      before( :each ) do
        @second_ticket_time = TicketTime.order( :started_at )[1]
        @last_ticket_time = TicketTime.order( :started_at )[2]
      end

      it "should set the second ticket time starting time to the beginning of the second day" do
        @second_ticket_time.started_at.should eql( Time.parse( "2010-12-29 00:00:00" ) )
      end

      it "should set the second ticket time ending time to the end of the second day" do
        @second_ticket_time.ended_at.should eql( Time.parse( "2010-12-29 23:59:59" ) )
      end

      it "should set the second ticket time worker id to the worker id" do
        @second_ticket_time.worker_id.should eql( @ticket_time.worker_id )
      end

      it "should set the second ticket time ticket id to the ticket id" do
        @second_ticket_time.ticket_id.should eql( @ticket_time.ticket_id )
      end

      it "should set the last ticket time starting time to the beginning of the last day" do
        @last_ticket_time.started_at.should eql( Time.parse( "2010-12-30 00:00:00" ) )
      end

      it "should set the last ticket time ending time to the end of ticket time span" do
        @last_ticket_time.ended_at.should eql( Time.parse( "2010-12-30 01:00:00" ) )
      end

      it "should set the last ticket time worker id to the worker id" do
        @last_ticket_time.worker_id.should eql( @ticket_time.worker_id )
      end

      it "should set the last ticket time ticket id to the ticket id" do
        @last_ticket_time.ticket_id.should eql( @ticket_time.ticket_id )
      end
    end
  end

  describe "with a non-dollar rate" do
    before( :each ) do
      Timecop.freeze
      @ticket = Factory( :ticket )
      @ticket.billing_rate.update_attributes!( :dollars => 80, :units => "total", :billable => @ticket, :hourly_rate_for_calculations => 100 )
    end

    after( :each ) do
      Timecop.return
    end

    it "should return 0 dollars earned if the previous earned is greater than the rate" do
      Factory( :ticket_time, :ticket => @ticket, :started_at => 2.hours.ago, :ended_at => 1.hour.ago )
      ticket_time = Factory( :ticket_time, :ticket => @ticket, :started_at => 1.hour.ago, :ended_at => Time.zone.now )
      ticket_time.dollars_earned.should eql( 0.0 )
    end

    it "should only return the part of the dollars earned that falls below the total rate" do
      Factory( :ticket_time, :ticket => @ticket, :started_at => 2.hours.ago, :ended_at => 90.minutes.ago )
      ticket_time = Factory( :ticket_time, :ticket => @ticket, :started_at => 1.hour.ago, :ended_at => Time.zone.now )
      ticket_time.dollars_earned.should eql( 30.0 )
    end
  end
end

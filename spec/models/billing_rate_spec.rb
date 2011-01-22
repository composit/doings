require 'spec_helper'

describe BillingRate do
  it "should validate with valid attributes" do
    Factory.build( :billing_rate ).should be_valid
  end

  it "should have numeric, non-empty dollars" do
    billing_rate = Factory.build( :billing_rate, :dollars => nil )
    billing_rate.save
    billing_rate.errors.should eql( :dollars => ["is not a number"] )
  end

  it "should have approved units" do
    billing_rate = Factory.build( :billing_rate, :units => nil )
    billing_rate.save
    billing_rate.errors.should eql( :units => ["are not included in the list"] )
  end

  it "should return an hourly description" do
    billing_rate = Factory( :billing_rate, :dollars => 10, :units => "hour" )

    billing_rate.description.should eql( "$10/hour" )
  end

  it "should return a monthly description" do
    client = Factory( :client, :name => "Test client" )
    billing_rate = Factory( :billing_rate, :dollars => 99, :units => "month", :billable => client )

    billing_rate.description.should eql( "$99/month for Test client" )
  end

  it "should return a total description" do
    project = Factory( :project, :name => "Test project" )
    billing_rate = Factory( :billing_rate, :dollars => 1000, :units => "total", :billable => project )

    billing_rate.description.should eql( "$1000 for Test project" )
  end

  it "should automatically assign the hourly_rate_for_goals for hourly billing rates" do
    billing_rate = Factory( :billing_rate, :dollars => 10, :units => "hour" )

    billing_rate.hourly_rate_for_calculations.should eql( 10.0 )
  end

  describe "when determining dollars remaining" do
    before( :each ) do
      Timecop.freeze( Time.zone.parse( "2010-10-15 10:00:00" ) )
      @client = Factory( :client )
      @project = Factory( :project, :client => @client )
      @ticket = Factory( :ticket, :project => @project )
      Factory( :ticket_time, :ticket => @ticket, :started_at => 1.month.ago, :ended_at => 1.month.ago + 1.hour )
      Factory( :ticket_time, :ticket => @ticket, :started_at => 1.day.ago, :ended_at => 23.hours.ago )
      @billing_rate = Factory( :billing_rate, :billable => @ticket, :dollars => 1000, :units => "total", :hourly_rate_for_calculations => 100 )
    end

    after( :each ) do
      Timecop.return
    end

    it "should return the dollars remaining associated with the billable item" do
      @billing_rate.dollars_remaining.should eql( 800.0 )
    end

    it "should not include dollars associated with other tickets if the billable item is a ticket" do
      other_ticket = Factory( :ticket, :project => @project )
      Factory( :ticket_time, :ticket => other_ticket, :started_at => 1.day.ago, :ended_at => 23.hours.ago )

      @billing_rate.dollars_remaining.should eql( 800.0 )
    end

    it "should not include dollars associated with other projects if the billable item is a project" do
      other_project = Factory( :project, :client => @client )
      other_ticket = Factory( :ticket, :project => other_project )
      Factory( :ticket_time, :ticket => other_ticket, :started_at => 1.day.ago, :ended_at => 23.hours.ago )

      @billing_rate.dollars_remaining.should eql( 800.0 )
    end

    it "should not include dollars associated with other clients if the billable item is a client" do
      other_client = Factory( :client )
      other_project = Factory( :project, :client => other_client )
      other_ticket = Factory( :ticket, :project => other_project )
      Factory( :ticket_time, :ticket => other_ticket, :started_at => 1.day.ago, :ended_at => 23.hours.ago )

      @billing_rate.dollars_remaining.should eql( 800.0 )
    end

    it "should not include dollars for tickets that started after or at the specified time" do
      (0..1).each do |n|
        @billing_rate.dollars_remaining( 1.day.ago - n.seconds ).should eql( 900.00 )
      end
    end

    it "should not include dollars earned before the current month if the rate is monthly" do
      @billing_rate.update_attributes!( :units => "month" )

      @billing_rate.dollars_remaining.should eql( 900.0 )
    end

    it "should return 0 if the calculated dollars earned is greater than the rate" do
      @billing_rate.update_attributes!( :dollars => 10 )

      @billing_rate.dollars_remaining.should eql( 0.0 )
    end
  end

  describe "when dealing with the billable choice" do
    before( :each ) do
      @client = Factory( :client, :id => 595 )
      @project = Factory( :project )
      @project.billing_rate.update_attributes!( :billable_choice => "Client:595" )
    end

    it "should set the billable via the billable_choice" do
      @project.billing_rate.billable.should eql( @client )
    end

    it "should return the billable_choice formated for the select dropdown" do
      @project.billing_rate.reload.billable_choice.should eql( "Client:595" )
    end
  end

  it "should return its marginal hourly rate, based on how close dollars earned are to the total" do
    ticket = Factory( :ticket )
    ticket.billing_rate.update_attributes!( :units => "total", :dollars => 100, :hourly_rate_for_calculations => 70, :billable => ticket )
    Factory( :ticket_time, :ticket => ticket, :started_at => 2.hours.ago, :ended_at => 1.hour.ago )

    ticket.billing_rate.marginal_hourly_rate.should eql( 30.0 )
    Factory( :ticket_time, :ticket => ticket, :started_at => 2.hours.ago, :ended_at => 1.hour.ago )

    ticket.billing_rate.marginal_hourly_rate.should eql( 0.0 )
  end
end

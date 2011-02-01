require 'spec_helper'

describe Invoice do
  it "should validate with valid attributes" do
    Factory.build( :invoice ).should be_valid
  end

  it "should not validate without a client" do
    invoice = Factory.build( :invoice, :client_id => nil )
    invoice.save

    invoice.errors.should eql( :client => ["can't be blank"] )
  end

  it "should nullify ticket_times' invoice_id fields when it gets deleted" do
    invoice = Factory( :invoice )
    ticket_time = Factory( :ticket_time, :invoice => invoice )
    invoice.destroy

    ticket_time.reload.invoice_id.should be_nil
  end

  it "should parse the invoice_date_string into the invoice_date" do
    invoice = Factory( :invoice, :invoice_date_string => "2010-01-01" )

    invoice.invoice_date.strftime( "%Y-%m-%d" ).should eql( "2010-01-01" )
  end

  it "should return an invoice_date_string given a date" do
    invoice = Factory( :invoice, :invoice_date => Date.parse( "2010-01-01" ) )

    invoice.invoice_date_string.should eql( "2010-01-01" )
  end

  it "should default the invoice_date_string to the current date" do
    Timecop.freeze( Time.parse( "2001-02-03" ) ) do
      invoice = Factory( :invoice, :invoice_date => nil )

      invoice.invoice_date_string.should eql( "2001-02-03" )
    end
  end

  describe "when figuring available ticket times" do
    before( :each ) do
      @client = Factory( :client )
      project = Factory( :project, :client => @client )
      ticket = Factory( :ticket, :project => project )
      @invoice = Factory( :invoice, :client => @client )
      @ticket_time_params = { :invoice => @invoice, :ticket => ticket, :started_at => 1.day.ago, :ended_at => 23.hours.ago }
    end

    it "should include ticket times that are associated with it" do
      ticket_time = Factory( :ticket_time, @ticket_time_params.merge( :ticket => Factory( :ticket ) ) )

      @invoice.available_ticket_times.collect { |ticket_time| ticket_time.id }.should eql( [ticket_time.id] )
    end

    it "should not include ticket times that are associated with other invoices" do
      ticket_time = Factory( :ticket_time, @ticket_time_params.merge( :invoice => Factory( :invoice ) ) )

      @invoice.available_ticket_times.should be_empty
    end

    it "should include ticket times from the same client without an associated invoice" do
      ticket_time = Factory( :ticket_time, @ticket_time_params.merge( :invoice => nil ) )

      @invoice.available_ticket_times.collect { |ticket_time| ticket_time.id }.should eql( [ticket_time.id] )
    end

    it "should not include ticket times from other clients" do
      ticket_time = Factory( :ticket_time, @ticket_time_params.merge( :invoice => nil, :ticket => Factory( :ticket ) ) )

      @invoice.available_ticket_times.should be_empty
    end

    it "should not include open ticket times" do
      ticket_time = Factory( :ticket_time, @ticket_time_params.merge( :ended_at => nil ) )

      @invoice.available_ticket_times.should be_empty
    end

    it "should order the ticket times ascending by date" do
      last_ticket_time = Factory( :ticket_time, @ticket_time_params.merge( :started_at => 24.hours.ago ) )
      first_ticket_time = Factory( :ticket_time, @ticket_time_params.merge( :started_at => 26.hours.ago ) )
      middle_ticket_time = Factory( :ticket_time, @ticket_time_params.merge( :started_at => 25.hours.ago ) )

      @invoice.available_ticket_times.collect { |ticket_time| ticket_time.id }.should eql( [first_ticket_time.id, middle_ticket_time.id, last_ticket_time.id] )
    end
  end

  describe "when including ticket times" do
    before( :each ) do
      @invoice = Factory( :invoice )
      ticket_time_params = { :invoice => @invoice, :started_at => 1.day.ago, :ended_at => 23.hours.ago, :ticket => Factory( :ticket, :project => Factory( :project, :client => @invoice.client ) ) }
      @ticket_time_one = Factory( :ticket_time, ticket_time_params )
      @ticket_time_two = Factory( :ticket_time, ticket_time_params.merge( :invoice => nil ) )
      @invoice.include_ticket_times = { @ticket_time_one.id => "0", @ticket_time_two.id => "1" }
    end

    it "should add ticket times that have been selected" do
      @ticket_time_one.reload.invoice_id.should be_nil
    end

    it "should remove ticket times that have not been selected" do
      @ticket_time_two.reload.invoice_id.should eql( @invoice.id )
    end

  end
end

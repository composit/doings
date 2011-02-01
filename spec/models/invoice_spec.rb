require 'spec_helper'

describe Invoice do
  it "should validate with valid attributes" do
    Factory.build( :invoice ).should be_valid
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
end

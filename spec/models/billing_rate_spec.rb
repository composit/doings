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

  it "should return a description" do
    billing_rate = Factory( :billing_rate, :dollars => 10, :units => "hour" )

    billing_rate.description.should eql( "$10/hour" )
  end


end

require 'spec_helper'

describe Client do
  it "should validate with valid attributes" do
    Factory.build( :client ).should be_valid
  end

  it "should require a name" do
    client = Factory.build( :client, :name => "" )
    client.save
    client.errors.should eql( :name => ["can't be blank"] )
  end

  it "should require a unique name" do
    Factory( :client, :name => "Test client" )
    client = Factory.build( :client, :name => "Test client" )
    client.save
    client.errors.should eql( :name => ["has already been taken"] )
  end

  it "should destroy associated billing rate when destroyed" do
    client = Factory( :client, :billing_rate => Factory( :billing_rate ) )
    client.destroy

    BillingRate.all.length.should eql( 0 )
  end

  it "should destroy associated address when destroyed" do
    client = Factory( :client, :address => Factory( :address ) )
    client.destroy

    Address.all.length.should eql( 0 )
  end
end

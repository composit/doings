require 'spec_helper'

describe Project do
  it "should validate with valid attributes" do
    Factory.build( :project ).should be_valid
  end

  it "should destroy associated billing rate when destroyed" do
    project = Factory( :project, :billing_rate => Factory( :billing_rate ) )
    BillingRate.all.length.should eql( 1 )
    project.destroy

    BillingRate.all.length.should eql( 0 )
  end

  it "should require a name" do
    project = Factory.build( :project, :name => "" )
    project.save

    project.errors.should eql( :name => ["can't be blank"] )
  end

  it "should allow non-unique names for differend clients" do
    client_one = Factory( :client )
    client_two = Factory( :client )
    Factory( :project, :client => client_one, :name => "Test project" )

    Factory( :project, :client => client_two, :name => "Test project" ).should be_valid
  end

  it "should require unique names for single client" do
    client = Factory( :client )
    Factory( :project, :client => client, :name => "Test project" )
    project = Factory.build( :project, :client => client, :name => "Test project" )
    project.save

    project.errors.should eql( :name => ["has already been taken"] )
  end
end

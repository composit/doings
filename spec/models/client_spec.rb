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

  it "should require the web address to be properly formatted" do
    client = Factory.build( :client, :web_address => "bad" )
    client.save

    client.errors.should eql( :web_address => ["is invalid"] )
  end

  it "should build a project with inherited user roles" do
    user_one = Factory( :user )
    user_two = Factory( :user )
    client = Factory( :client )
    Factory( :user_role, :user => user_one, :manageable => client )
    Factory( :user_role, :user => user_two, :manageable => client )
    project = client.build_project_with_inherited_roles( user_one.id )

    project.user_roles.collect { |t| t.user_id }.should eql( [user_one.id, user_two.id] )
  end
end

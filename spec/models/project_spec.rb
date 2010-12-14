require 'spec_helper'

describe Project do
  it "should validate with valid attributes" do
    Factory.build( :project ).should be_valid
  end

  it "should require a created by user" do
    project = Factory.build( :project, :created_by_user_id => nil )
    project.save

    project.errors.should eql( :created_by_user_id => ["can't be blank"] )
  end

  it "should destroy associated billing rate when destroyed" do
    project = Factory( :project )
    billing_rate = project.billing_rate
    project.destroy

    BillingRate.where( :id => billing_rate.id ).should be_empty
  end

  it "should require a name" do
    project = Factory.build( :project, :name => "" )
    project.save

    project.errors.should eql( :name => ["can't be blank"] )
  end

  it "should require a client" do
    project = Factory.build( :project, :client => nil )
    project.save

    project.errors.should eql( :billing_rate => ["can't be blank"], :client => ["can't be blank"] )
  end

  it "should allow non-unique names for different clients" do
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

  it "should build a ticket with inherited user roles" do
    user_one = Factory( :user )
    user_two = Factory( :user )
    project = Factory( :project )
    Factory( :user_role, :user => user_one, :manageable => project )
    Factory( :user_role, :user => user_two, :manageable => project )
    ticket = project.reload.build_inherited_ticket( user_one.id )

    ticket.user_roles.collect { |t| t.user_id }.should eql( [user_one.id, user_two.id] )
  end

  it "should build a ticket with inherited billing rate" do
    user = Factory( :user )
    project = Factory( :project, :billing_rate => Factory( :billing_rate, :dollars => 10, :units => "hour" ) )
    ticket = project.build_inherited_ticket( user.id )

    ticket.billing_rate.dollars.should eql( 10 )
    ticket.billing_rate.units.should eql( "hour" )
  end

  it "should generate user activity alerts when created" do
    user_one = Factory( :user, :username => "tester" )
    user_two = Factory( :user )
    project = Factory( :project, :name => "Test project", :created_by_user => user_one, :user_roles_attributes => [{ :user => user_two }] )

    user_two.user_activity_alerts.first.content.should eql( "tester created a new project called Test project" )
  end

  it "should not generate user activity alerts for people not associated with that project" do
    user_one = Factory( :user, :username => "tester" )
    user_two = Factory( :user )
    project = Factory( :project, :name => "Test project", :created_by_user => user_one, :user_roles_attributes => [{ :user => user_one }] )

    user_two.user_activity_alerts.should be_empty
  end

  it "should return ticket times associated with it" do
    project = Factory( :project )
    ticket = Factory( :ticket, :project => project )
    other_ticket = Factory( :ticket, :project => project )
    ticket_time = Factory( :ticket_time, :ticket => ticket )
    other_ticket_time = Factory( :ticket_time, :ticket => other_ticket )
    Factory( :ticket_time )

    project.ticket_times.collect { |ticket_time| ticket_time.id }.should eql( [ticket_time.id, other_ticket_time.id] )
  end

  it "should automatically adopt the client's billing rate if no billing rate is set" do
    client = Factory( :client, :billing_rate => Factory( :billing_rate, :dollars => 100, :units => "month" ) )
    project = Factory( :project, :client => client, :billing_rate => nil )

    project.billing_rate.dollars.should eql( 100 )
    project.billing_rate.units.should eql( "month" )
  end
end

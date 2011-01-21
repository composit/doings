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

  it "should require a billing rate" do
    client = Factory.build( :client, :billing_rate => nil )
    client.save

    client.errors.should eql( :billing_rate => ["can't be blank"] )
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
    project = client.build_inherited_project( user_one.id )

    project.user_roles.collect { |t| t.user_id }.should eql( [user_one.id, user_two.id] )
  end

  it "should build a project with inherited billing rate" do
    user = Factory( :user )
    client = Factory( :client )
    client.billing_rate.update_attributes!( :dollars => 10, :units => "hour", :billable => client )
    project = client.build_inherited_project( user.id )

    project.billing_rate.dollars.should eql( 10 )
    project.billing_rate.units.should eql( "hour" )
    project.billing_rate.billable.should eql( client )
  end

  it "should return ticket times associated with it" do
    client = Factory( :client )
    project = Factory( :project, :client => client )
    other_project = Factory( :project, :client => client )
    ticket = Factory( :ticket, :project => project )
    other_ticket = Factory( :ticket, :project => other_project )
    ticket_time = Factory( :ticket_time, :ticket => ticket )
    other_ticket_time = Factory( :ticket_time, :ticket => other_ticket )
    Factory( :ticket_time )

    client.ticket_times.collect { |ticket_time| ticket_time.id }.should eql( [ticket_time.id, other_ticket_time.id] )
  end

  it "should return tickets associated with it" do
    client = Factory( :client )
    project = Factory( :project, :client => client )
    other_project = Factory( :project, :client => client )
    ticket = Factory( :ticket, :project => project )
    other_ticket = Factory( :ticket, :project => other_project )
    Factory( :ticket )

    client.tickets.collect { |ticket| ticket.id }.should eql( [ticket.id, other_ticket.id] )
  end

  it "should determine billable options" do
    client = Factory( :client, :name => "Test client", :id => 345 )
    
    client.billable_options.should eql( [["Test client","Client:345"]] )
  end

  it "should include a generic 'this client' option in the billable options for new client records" do
    Client.new.billable_options.should eql( [["this client","Client:"]] )
  end

  it "should set itself as the billable for its billing rate if it is not set" do
    client = Client.create( :name => "Test client", :created_by_user => Factory( :user ), :billing_rate_attributes => { :units => "month", :dollars => 100 } )

    client.billing_rate.reload.billable.should eql( client )
  end
end

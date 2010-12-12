require 'spec_helper'

describe Ticket do
  it "should validate with valid attributes" do
    Factory.build( :ticket ).should be_valid
  end

  it "should require a name" do
    ticket = Factory.build( :ticket, :name => "" )
    ticket.save

    ticket.errors.should eql( :name => ["can't be blank"] )
  end

  it "should require a created by user" do
    ticket = Factory.build( :ticket, :created_by_user_id => nil )
    ticket.save

    ticket.errors.should eql( :created_by_user_id => ["can't be blank"] )
  end

  it "should allow non-unique names for differend projects" do
    project_one = Factory( :project )
    project_two = Factory( :project )
    Factory( :ticket, :project => project_one, :name => "Test ticket" )

    Factory( :ticket, :project => project_two, :name => "Test ticket" ).should be_valid
  end

  it "should require unique names for single project" do
    project = Factory( :project )
    Factory( :ticket, :project => project, :name => "Test ticket" )
    ticket = Factory.build( :ticket, :project => project, :name => "Test ticket" )
    ticket.save

    ticket.errors.should eql( :name => ["has already been taken"] )
  end

  it "should destroy associated billing rate when destroyed" do
    ticket = Factory( :ticket, :billing_rate => Factory( :billing_rate ) )
    ticket.destroy

    BillingRate.all.length.should eql( 0 )
  end

  it "should only allow numerical estimated minutes" do
    ticket = Factory.build( :ticket, :estimated_minutes => "abc" )
    ticket.save

    ticket.errors.should eql( :estimated_minutes => ["is not a number"] )
  end

  it "should generate user activity alerts when created" do
    user_one = Factory( :user, :username => "tester" )
    user_two = Factory( :user )
    ticket = Factory( :ticket, :name => "Test ticket", :created_by_user => user_one, :user_roles_attributes => [{ :user => user_two }] )

    user_two.user_activity_alerts.first.content.should eql( "tester created a new ticket called Test ticket" )
  end

  it "should not generate user activity alerts for people not associated with the ticket" do
    user_one = Factory( :user, :username => "tester" )
    user_two = Factory( :user )
    ticket = Factory( :ticket, :name => "Test ticket", :created_by_user => user_one, :user_roles_attributes => [{ :user => user_one }] )

    user_two.user_activity_alerts.should be_empty
  end
end

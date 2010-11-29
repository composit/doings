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
end

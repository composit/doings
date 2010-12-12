require 'spec_helper'

describe Project do
  it "should validate with valid attributes" do
    Factory.build( :project ).should be_valid
  end

  it "should destroy associated billing rate when destroyed" do
    project = Factory( :project, :billing_rate => Factory( :billing_rate ) )
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

  it "should build a ticket with inherited user roles" do
    user_one = Factory( :user )
    user_two = Factory( :user )
    project = Factory( :project )
    Factory( :user_role, :user => user_one, :manageable => project )
    Factory( :user_role, :user => user_two, :manageable => project )
    ticket = project.reload.build_ticket_with_inherited_roles( user_one.id )

    ticket.user_roles.collect { |t| t.user_id }.should eql( [user_one.id, user_two.id] )
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
end

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
    project = Factory( :project )
    project.billing_rate.update_attributes!( :dollars => 10, :units => "hour", :billable => project )
    ticket = project.build_inherited_ticket( user.id )

    ticket.billing_rate.dollars.should eql( 10 )
    ticket.billing_rate.units.should eql( "hour" )
    ticket.billing_rate.billable.should eql( project )
  end

  it "should generate user activity alerts when created" do
    user_one = Factory( :user, :username => "tester" )
    user_two = Factory( :user )
    project = Factory( :project, :name => "Test project", :updated_by_user_id => user_one.id, :user_roles_attributes => [{ :user => user_two }] )

    user_two.user_activity_alerts.first.content.should eql( "tester created a project called Test project" )
  end

  it "should generate user activity alerts when updated" do
    user_one = Factory( :user, :username => "tester" )
    user_two = Factory( :user, :username => "other" )
    project = Factory( :project, :name => "Test project", :updated_by_user_id => user_one.id, :user_roles_attributes => [{ :user => user_two }, { :user => user_one }] )
    project.update_attributes!( :name => "New name", :updated_by_user_id => user_two.id )

    user_one.user_activity_alerts.first.content.should eql( "other updated a project called New name" )
  end

  it "should not generate user activity alerts for people not associated with that project" do
    user_one = Factory( :user, :username => "tester" )
    user_two = Factory( :user )
    project = Factory( :project, :name => "Test project", :created_by_user => user_one, :updated_by_user_id => user_one.id, :user_roles_attributes => [{ :user => user_one }] )

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

  it "should determine billable options" do
    client = Factory( :client, :name => "Test client", :id => 456 )
    project = Factory( :project, :client => client, :name => "Test project", :id => 987 )

    project.billable_options.should eql( [["Test project", "Project:987"],["Test client", "Client:456"]] )
  end

  it "should include a generic 'this project' option in the billable options for new project records" do
    client = Factory( :client, :name => "Test client", :id => 456 )
    project = Project.new( :client => client )

    project.billable_options.should eql( [["this project", "Project:"],["Test client", "Client:456"]] )
  end

  it "should set itself as the billable for its billing rate if it is not set" do
    project = Project.create( :name => "Test project", :created_by_user => Factory( :user ), :client => Factory( :client ), :billing_rate_attributes => { :units => "month", :dollars => 100 } )

    project.billing_rate.reload.billable.should eql( project )
  end

  it "should set closed_at to the current time when 'close project' is set to 1" do
    Timecop.freeze( Time.parse( "2001-02-03 04:05:06" ) )
    project = Factory( :project )

    project.update_attributes!( :close_project => "1" )
    project.closed_at.strftime( "%Y-%m-%d %H:%M:%S" ).should eql( "2001-02-03 04:05:06" )
  end

  it "should not set closed_at if 'close project' is not set to 1" do
    Timecop.freeze( Time.parse( "2001-02-03 04:05:06" ) )
    project = Factory( :project )

    project.update_attributes!( :close_project => "0" )
    project.reload.closed_at.should be_nil
    Timecop.return
  end

  it "should close all of its tickets when it closes" do
    Timecop.freeze( Time.parse( "2001-02-03 04:05:06" ) )
    project = Factory( :project )
    ticket_one = Factory( :ticket, :project => project )
    ticket_two = Factory( :ticket, :project => project )

    project.update_attributes!( :closed_at => Time.zone.now )
    ticket_one.reload.closed_at.strftime( "%Y-%m-%d %H:%M:%S" ).should eql( "2001-02-03 04:05:06" )
    ticket_two.reload.closed_at.strftime( "%Y-%m-%d %H:%M:%S" ).should eql( "2001-02-03 04:05:06" )
    Timecop.return
  end

  it "should not close other tickets when it closes" do
    project = Factory( :project )
    ticket = Factory( :ticket )

    project.update_attributes!( :closed_at => Time.zone.now )
    ticket.reload.closed_at.should be_nil
  end

  it "should not update the closed_at times of already-closed tickets when it closes" do
    Timecop.freeze( Time.parse( "2001-02-03 04:05:06" ) )
    project = Factory( :project )
    ticket = Factory( :ticket, :project => project, :closed_at => "2001-01-01 01:01:01" )

    project.update_attributes!( :closed_at => Time.zone.now )
    ticket.reload.closed_at.strftime( "%Y-%m-%d %H:%M:%S" ).should eql( "2001-01-01 01:01:01" )
    Timecop.return
  end

  describe "when calculating minutes" do
    before( :each ) do
      @project = Factory( :project )
      ticket_one = Factory( :ticket, :project => @project, :estimated_minutes => 100 )
      ticket_two = Factory( :ticket, :project => @project, :estimated_minutes => 80 )
      Factory( :ticket_time, :ticket => ticket_one, :started_at => 1.day.ago, :ended_at => 23.hours.ago )
      Factory( :ticket_time, :ticket => ticket_two, :started_at => 30.minutes.ago, :ended_at => Time.zone.now )
    end

    it "should add up the estimated minutes for the tickets" do
      @project.estimated_minutes.should eql( 180.0 )
    end

    it "should not include estimated minutes for other projects' tickets" do
      Factory( :ticket, :project => Factory( :project ), :estimated_minutes => 10 )

      @project.estimated_minutes.should eql( 180.0 )

    end

    it "should total the minutes worked for its tickets" do
      @project.minutes_worked.should eql( 90.0 )
    end

    it "should not include minutes worked for other tickets" do
      Factory( :ticket_time, :ticket => Factory( :ticket ), :started_at => 1.day.ago, :ended_at => 1.hour.ago )

      @project.minutes_worked.should eql( 90.0 )
    end
  end
end

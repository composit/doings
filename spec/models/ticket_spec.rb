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

  it "should require a project" do
    ticket = Factory.build( :ticket, :project => nil )
    ticket.save

    ticket.errors.should eql( :billing_rate => ["can't be blank"], :project => ["can't be blank"] )
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
    ticket = Factory( :ticket )
    billing_rate = ticket.billing_rate
    ticket.destroy

    BillingRate.where( :id => billing_rate.id ).should be_empty
  end

  it "should generate user activity alerts when created" do
    user_one = Factory( :user, :username => "tester" )
    user_two = Factory( :user )
    ticket = Factory( :ticket, :name => "Test ticket", :updated_by_user_id => user_one.id, :user_roles_attributes => [{ :user => user_two }] )

    user_two.user_activity_alerts.first.content.should eql( "tester created a ticket called Test ticket" )
  end

  it "should generate user activity alerts when updated" do
    user_one = Factory( :user, :username => "tester" )
    user_two = Factory( :user, :username => "other" )
    ticket = Factory( :ticket, :name => "Test ticket", :updated_by_user_id => user_one.id, :user_roles_attributes => [{ :user => user_two }, { :user => user_one }] )
    ticket.update_attributes!( :name => "New name", :updated_by_user_id => user_two.id )

    user_one.user_activity_alerts.first.content.should eql( "other updated a ticket called New name" )
  end

  it "should not generate user activity alerts for people not associated with the ticket" do
    user_one = Factory( :user, :username => "tester" )
    user_two = Factory( :user )
    ticket = Factory( :ticket, :name => "Test ticket", :updated_by_user_id => user_one.id, :user_roles_attributes => [{ :user => user_one }] )

    user_two.user_activity_alerts.should be_empty
  end

  it "should determine billable options" do
    client = Factory( :client, :name => "Test client", :id => 456 )
    project = Factory( :project, :client => client, :name => "Test project", :id => 883 )
    ticket = Factory( :ticket, :project => project, :name => "Test ticket", :id => 585 )

    ticket.billable_options.should eql( [["Test ticket","Ticket:585"],["Test project","Project:883"],["Test client","Client:456"]] )
  end

  it "should include a generic 'this ticket' in the billable options of a new ticket" do
    client = Factory( :client, :name => "Test client", :id => 456 )
    project = Factory( :project, :client => client, :name => "Test project", :id => 883 )
    ticket = Ticket.new( :project => project )

    ticket.billable_options.should eql( [["this ticket","Ticket:"],["Test project","Project:883"],["Test client","Client:456"]] )
  end

  it "should set itself as the billable for its billing rate if it is not set" do
    ticket = Ticket.create( :name => "Test ticket", :created_by_user => Factory( :user ), :project => Factory( :project ), :billing_rate_attributes => { :units => "month", :dollars => 100 } )

    ticket.billing_rate.reload.billable.should eql( ticket )
  end

  it "should generate a full name" do
    client = Factory( :client, :name => "Test client" )
    project = Factory( :project, :name => "Test project", :client => client )
    ticket = Factory( :ticket, :name => "Test ticket", :project => project )

    ticket.full_name.should eql( "Test client - Test project - Test ticket" )
  end

  it "should return the priority for a specific user" do
    user = Factory( :user )
    other_user = Factory( :user )
    ticket = Factory( :ticket )
    Factory( :user_role, :user => other_user, :manageable => ticket, :priority => 10 )
    Factory( :user_role, :user => user, :manageable => ticket, :priority => 5 )

    ticket.priority_for_user( user ).should eql( 5 )
  end

  describe "when reprioritizing" do
    before( :each ) do
      @user = Factory( :user )
      @ticket_one = Factory( :ticket, :id => 1 )
      @ticket_two = Factory( :ticket, :id => 2 )
      @ticket_three = Factory( :ticket, :id => 3 )
      Factory( :user_role, :user => @user, :manageable => @ticket_one, :priority => 1 )
      Factory( :user_role, :user => @user, :manageable => @ticket_two, :priority => 2 )
      Factory( :user_role, :user => @user, :manageable => @ticket_three, :priority => 3 )
    end

    it "should reprioritize tickets" do
      Ticket.reprioritize!( @user, { "1" => { "old" => "1", "new" => "2" }, "2" => { "old" => "2", "new" => "1" }, "3" => { "old" => "3", "new" => "3" } } )
      @ticket_one.reload.priority_for_user( @user ).should eql( 2 )
      @ticket_two.reload.priority_for_user( @user ).should eql( 1 )
      @ticket_three.reload.priority_for_user( @user ).should eql( 3 )
    end

    it "should favor the values of changing priorities if they overlap and the changing priorities are decreasing" do
      Ticket.reprioritize!( @user, { "1" => { "old" => "1", "new" => "1" }, "2" => { "old" => "2", "new" => "2" }, "3" => { "old" => "3", "new" => "2" } } )
      @ticket_one.reload.priority_for_user( @user ).should eql( 1 )
      @ticket_two.reload.priority_for_user( @user ).should eql( 3 )
      @ticket_three.reload.priority_for_user( @user ).should eql( 2 )
    end

    it "should favor the values of changing priorities if they overlap and the changing priorities are increasing" do
      Ticket.reprioritize!( @user, { "1" => { "old" => "1", "new" => "2" }, "2" => { "old" => "2", "new" => "2" }, "3" => { "old" => "3", "new" => "3" } } )
      @ticket_one.reload.priority_for_user( @user ).should eql( 2 )
      @ticket_two.reload.priority_for_user( @user ).should eql( 1 )
      @ticket_three.reload.priority_for_user( @user ).should eql( 3 )
    end

    it "should fill in gaps in priority" do
      Ticket.reprioritize!( @user, { "1" => { "old" => "1", "new" => "10" }, "2" => { "old" => "2", "new" => "100" }, "3" => { "old" => "3", "new" => "5" } } )
      @ticket_one.reload.priority_for_user( @user ).should eql( 2 )
      @ticket_two.reload.priority_for_user( @user ).should eql( 3 )
      @ticket_three.reload.priority_for_user( @user ).should eql( 1 )
    end

    it "should not reprioritize other users' tickets" do
      other_user = Factory( :user )
      other_user_role = Factory( :user_role, :user => other_user, :manageable => @ticket_one, :priority => 999 )
      Ticket.reprioritize!( @user, { "1" => { "old" => "1", "new" => "2" }, "2" => { "old" => "2", "new" => "1" }, "3" => { "old" => "3", "new" => "3" } } )

      other_user_role.priority.should eql( 999 )
    end

    it "should assign priority-less (new) tickets lowest priority" do
      ticket = Factory( :ticket, :user_roles_attributes => { "0" => { :user_id => @user.id } }, :updated_by_user_id => @user.id )
      ticket.reload.priority_for_user( @user ).should eql( 4 )
    end

    it "should not overwrite priorities if they exist" do
      ticket = Factory( :ticket, :user_roles_attributes => { "0" => { :user_id => @user.id, :priority => 10 } }, :updated_by_user_id => @user.id )
      ticket.reload.priority_for_user( @user ).should eql( 10 )
    end

    it "should automatically set the first created ticket's priority to 1" do
      user = Factory( :user )
      ticket = Factory( :ticket, :user_roles_attributes => { "0" => { :user_id => user.id } }, :updated_by_user_id => @user.id )
      ticket.reload.priority_for_user( user ).should eql( 1 )
    end
  end

  it "should close if its project is closed" do
    Timecop.freeze( Time.parse( "2001-02-03 04:05:06" ) )
    project = Factory( :project, :closed_at => "2001-01-01 01:01:01" )
    ticket = Factory( :ticket, :project => project )

    ticket.closed_at.strftime( "%Y-%m-%d %H:%M:%S" ).should eql( "2001-02-03 04:05:06" )
    Timecop.return
  end

  it "should not automatically close if project is not closed" do
    project = Factory( :project )
    ticket = Factory( :ticket, :project => project )

    ticket.closed_at.should be_nil
  end

  it "should set closed_at to the current time when 'close ticket' is set to 1" do
    Timecop.freeze( Time.parse( "2001-02-03 04:05:06" ) )
    ticket = Factory( :ticket )

    ticket.update_attributes!( :close_ticket => "1" )
    ticket.closed_at.strftime( "%Y-%m-%d %H:%M:%S" ).should eql( "2001-02-03 04:05:06" )
    Timecop.return
  end

  it "should not set closed_at if 'close ticket' is not set to 1" do
    Timecop.freeze( Time.parse( "2001-02-03 04:05:06" ) )
    ticket = Factory( :ticket )

    ticket.update_attributes!( :close_ticket => "0" )
    ticket.reload.closed_at.should be_nil
    Timecop.return
  end

  describe "when determining minutes worked" do
    before( :each ) do
      @ticket = Factory( :ticket )
    end

    it "should include minutes worked for that ticket" do
      Factory( :ticket_time, :ticket => @ticket, :started_at => 1.day.ago, :ended_at => 23.hours.ago )

      @ticket.minutes_worked.should eql( 60.0 )
    end

    it "should not include minutes worked for other tickets" do
      Factory( :ticket_time, :started_at => 1.day.ago, :ended_at => 23.hours.ago )

      @ticket.minutes_worked.should eql( 0.0 )
    end
  end

  it "should numericalize estimated minutes" do
    ticket = Factory( :ticket, :estimated_minutes => "abc" )

    ticket.estimated_minutes.should eql( 0 )
  end
end

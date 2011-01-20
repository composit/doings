require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  #TODO nest each model - create a scenario with good attributes and take away attributes for each test
  before( :each ) do
    @user = Factory( :user )
    @ability = Ability.new( @user )
  end

  describe "for a client" do
    before( :each ) do
      @client = Factory( :client, :active => true )
      @user_role = Factory( :user_role, :user => @user, :manageable => @client, :admin => true, :finances => true, :worker => true )
    end

    it "should not allow read access to users who are not associated" do
      @user_role.destroy

      @ability.should_not be_able_to( :read, @client )
    end

    it "should allow read access to users who are associated" do
      @user_role.update_attributes!( :admin => false, :finances => false, :worker => false )

      @ability.should be_able_to( :read, @client )
    end
    
    it "should allow all users create access" do
      @ability.should be_able_to( :create, Client.new )
    end

    it "should not allow update access to users who are not associated" do
      @ability.should_not be_able_to( :update, Factory( :client ) )
    end

    it "should not allow update access to users who are associated but don't have admin access" do
      @user_role.update_attributes!( :admin => false )

      @ability.should_not be_able_to( :update, @client )
    end

    it "should allow update access to users who are associated with admin rights" do
      @user_role.update_attributes!( :finances => false, :worker => false )

      @ability.should be_able_to( :update, @client )
    end

    it "should not be able to read finances if not associated" do
      @ability.should_not be_able_to( :read_finances, Factory( :client ) )
    end

    it "should not be able to read finances if finances rights are not given" do
      @user_role.update_attributes!( :finances => false )

      @ability.should_not be_able_to( :read_finances, @client )
    end

    it "should be able to read finances if finances rights are given" do
      client = Factory( :client )
      Factory( :user_role, :user => @user, :manageable => client, :finances => true )

      @ability.should be_able_to( :read_finances, client )
    end

    it "should not be able to manage finances if not associated with the client" do
      @ability.should_not be_able_to( :manage_finances, Factory( :client ) )
    end

    it "should not be able to manage finances if finances rights are not given" do
      @user_role.update_attributes!( :finances => false )

      @ability.should_not be_able_to( :manage_finances, @client )
    end

    it "should not be able to manage finances if admin rights are not given" do
      @user_role.update_attributes!( :admin => false )

      @ability.should_not be_able_to( :manage_finances, @client )
    end

    it "should be able to manage finances for a client if finances and admin rights are given" do
      client = Factory( :client )
      Factory( :user_role, :user => @user, :manageable => client, :finances => true, :admin => true )

      @ability.should be_able_to( :manage_finances, client )
    end

    it "should not be able to workables if not associated with the client" do
      @ability.should_not be_able_to( :workables, Factory( :client ) )
    end

    it "should not be able to workables if worker rights are not given" do
      @user_role.update_attributes!( :worker => false )

      @ability.should_not be_able_to( :workables, @client )
    end

    it "should be able to workables if worker rights are given" do
      client = Factory( :client, :active => true )
      Factory( :user_role, :user => @user, :manageable => client, :worker => true )

      @ability.should be_able_to( :workables, client )
    end

    it "should not be able to get workables for an inactive client" do
      @client.update_attributes!( :active => false )

      @ability.should_not be_able_to( :workables, @client )
    end
  end

  describe "for a project" do
    before( :each ) do
      @project = Factory( :project )
      @user_role = Factory( :user_role, :user => @user, :manageable => @project, :admin => true, :finances => true, :worker => true )
    end

    it "should not allow read access to users who are not associated" do
      @ability.should_not be_able_to( :read, Factory( :project ) )
    end

    it "should allow read access to users who are associated" do
      project = Factory( :project )
      Factory( :user_role, :user => @user, :manageable => project )

      @ability.should be_able_to( :read, project )
    end

    it "should not allow create access to users who are not associated with a client" do
      client = Factory( :client )

      @ability.should_not be_able_to( :create, Factory.build( :project, :client => client ) )
    end

    it "should not allow create access to users who are associated with but don't have admin access to a client" do
      client = Factory( :client )
      Factory( :user_role, :user => @user, :manageable => client, :admin => false )

      @ability.should_not be_able_to( :create, Factory.build( :project, :client => client ) )
    end

    it "should allow create access to users who are associated with admin rights to a client" do
      client = Factory( :client )
      Factory( :user_role, :user => @user, :manageable => client, :admin => true )

      @ability.should be_able_to( :create, Factory.build( :project, :client => client ) )
    end

    it "should not allow update access to users who are not associated" do
      @ability.should_not be_able_to( :update, Factory( :project ) )
    end

    it "should not allow update access to users who are associated but don't have admin access" do
      @user_role.update_attributes!( :admin => false )

      @ability.should_not be_able_to( :update, @project )
    end

    it "should allow update access to users who are associated with admin rights" do
      project = Factory( :project )
      Factory( :user_role, :user => @user, :manageable => project, :admin => true )

      @ability.should be_able_to( :update, project )
    end

    it "should not be able to read finances if not associated" do
      @ability.should_not be_able_to( :read_finances, Factory( :project ) )
    end

    it "should not be able to read finances if finances rights are not given" do
      @user_role.update_attributes!( :finances => false )

      @ability.should_not be_able_to( :read_finances, @project )
    end

    it "should be able to read finances if finances rights are given" do
      project = Factory( :project )
      Factory( :user_role, :user => @user, :manageable => project, :finances => true )

      @ability.should be_able_to( :read_finances, project )
    end

    it "should not be able to manage finances if not associated" do
      @ability.should_not be_able_to( :manage_finances, Factory( :project ) )
    end

    it "should not be able to manage finances if finances rights are not given" do
      @user_role.update_attributes!( :finances => false )

      @ability.should_not be_able_to( :manage_finances, @project )
    end

    it "should not be able to manage finances if admin rights are not given" do
      @user_role.update_attributes!( :admin => false )

      @ability.should_not be_able_to( :manage_finances, @project )
    end

    it "should be able to manage finances if finances and admin rights are given" do
      project = Factory( :project )
      Factory( :user_role, :user => @user, :manageable => project, :finances => true, :admin => true )

      @ability.should be_able_to( :manage_finances, project )
    end

    it "should not be able to workables if not associated" do
      @user_role.delete

      @ability.should_not be_able_to( :workables, @project )
    end

    it "should not be able to workables if worker rights are not given" do
      @user_role.update_attributes!( :worker => false )

      @ability.should_not be_able_to( :workables, @project )
    end

    it "should be able to workables if worker rights are given" do
      project = Factory( :project )
      Factory( :user_role, :user => @user, :manageable => project, :worker => true )

      @ability.should be_able_to( :workables, project )
    end

    it "should not be able to workables for a closed project" do
      @project.update_attributes!( :closed_at => Time.zone.now )

      @ability.should_not be_able_to( :workables, @project )
    end
  end

  describe "for a ticket" do
    before( :each ) do
      @ticket = Factory( :ticket )
      @user_role = Factory( :user_role, :user => @user, :manageable => @ticket, :admin => true, :worker => true, :finances => true )
    end

    it "should not allow read access to users who are not associated" do
      @user_role.delete

      @ability.should_not be_able_to( :read, @ticket )
    end

    it "should allow read access to users who are associated" do
      ticket = Factory( :ticket )
      Factory( :user_role, :user => @user, :manageable => ticket )

      @ability.should be_able_to( :read, ticket.reload )
    end

    it "should not allow create access to users who are not associated with a project" do
      project = Factory( :project )

      @ability.should_not be_able_to( :create, Factory.build( :ticket, :project => project ) )
    end

    it "should not allow create access to users who are associated with but don't have admin access to a project" do
      project = Factory( :project )
      Factory( :user_role, :user => @user, :manageable => project, :admin => false )

      @ability.should_not be_able_to( :create, Factory.build( :ticket, :project => project ) )
    end

    it "should allow create access to users who are associated with admin rights to a project" do
      project = Factory( :project )
      Factory( :user_role, :user => @user, :manageable => project, :admin => true )

      @ability.should be_able_to( :create, Factory.build( :ticket, :project => project ) )
    end

    it "should not allow update access to users who are not associated" do
      @user_role.delete

      @ability.should_not be_able_to( :update, @ticket )
    end

    it "should not allow update access to users who are associated but don't have admin access" do
      @user_role.update_attributes!( :admin => false )

      @ability.should_not be_able_to( :update, @ticket.reload )
    end

    it "should allow update access to users who are associated with admin rights" do
      ticket = Factory( :ticket )
      Factory( :user_role, :user => @user, :manageable => ticket, :admin => true )

      @ability.should be_able_to( :update, ticket.reload )
    end

    it "should not be able to read finances if not associated" do
      @user_role.delete

      @ability.should_not be_able_to( :read_finances, @ticket.reload )
    end

    it "should not be able to read finances if finances rights are not given" do
      @user_role.update_attributes!( :finances => false )

      @ability.should_not be_able_to( :read_finances, @ticket.reload )
    end

    it "should be able to read finances if finances rights are given" do
      ticket = Factory( :ticket )
      Factory( :user_role, :user => @user, :manageable => ticket, :finances => true )

      @ability.should be_able_to( :read_finances, ticket.reload )
    end

    it "should not be able to manage finances if not associated" do
      @user_role.delete

      @ability.should_not be_able_to( :manage_finances, @ticket.reload )
    end

    it "should not be able to manage finances if finances rights are not given" do
      @user_role.update_attributes!( :finances => false )

      @ability.should_not be_able_to( :manage_finances, @ticket.reload )
    end

    it "should not be able to manage finances if admin rights are not given" do
      @user_role.update_attributes!( :admin => false )

      @ability.should_not be_able_to( :manage_finances, @ticket.reload )
    end

    it "should be able to manage finances if finances and admin rights are given" do
      ticket = Factory( :ticket )
      Factory( :user_role, :user => @user, :manageable => ticket, :finances => true, :admin => true )

      @ability.should be_able_to( :manage_finances, ticket.reload )
    end

    it "should not be able to workables if not associated" do
      @user_role.delete

      @ability.should_not be_able_to( :workables, @ticket.reload )
    end

    it "should not be able to workables if worker rights are not given" do
      @user_role.update_attributes!( :worker => false )

      @ability.should_not be_able_to( :workables, @ticket.reload )
    end

    it "should be able to workables if worker rights are given" do
      ticket = Factory( :ticket )
      Factory( :user_role, :user => @user, :manageable => ticket, :worker => true )

      @ability.should be_able_to( :workables, ticket.reload )
    end

    it "should not be able to workables for a closed ticket" do
      @ticket.update_attributes!( :closed_at => Time.zone.now )

      @ability.should_not be_able_to( :workables, @ticket.reload )
    end

    it "should not be able to prioritize if not associated" do
      @user_role.delete

      @ability.should_not be_able_to( :prioritize, @ticket.reload )
    end

    it "should not be able to prioritize if worker rights are not given" do
      @user_role.update_attributes!( :worker => false )

      @ability.should_not be_able_to( :prioritize, @ticket.reload )
    end

    it "should be able to prioritize if worker rights are given" do
      ticket = Factory( :ticket )
      Factory( :user_role, :user => @user, :manageable => ticket, :worker => true )

      @ability.should be_able_to( :prioritize, ticket.reload )
    end
  end

  it "should not be able to manage a goal that does not belong to it" do
    @ability.should_not be_able_to( :manage, Factory( :goal ) )
  end

  it "should be able to manage a goal that belongs to it" do
    Factory( :weekday_workweek, :worker_id => @user.id )
    goal = Factory( :goal, :user_id => @user.id )
    
    @ability.should be_able_to( :manage, goal )
  end

  it "should not be able to manage a workweek that does not belong to it" do
    @ability.should_not be_able_to( :manage, Factory( :workweek, :worker => Factory( :user ) ) )
  end

  it "should be able to manage a workweek that belongs to it" do
    workweek = Factory( :workweek, :worker_id => @user.id )
    
    @ability.should be_able_to( :manage, workweek )
  end
end

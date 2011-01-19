require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  before( :each ) do
    @user = Factory( :user )
    @ability = Ability.new( @user )
  end

  it "should not allow read access to users who are not associated with a client" do
    @ability.should_not be_able_to( :read, Factory( :client ) )
  end

  it "should allow read access to users who are associated with a client" do
    client = Factory( :client )
    Factory( :user_role, :user => @user, :manageable => client )

    @ability.should be_able_to( :read, client )
  end
  
  it "should allow all users create access to a client" do
    @ability.should be_able_to( :create, Client.new )
  end

  it "should not allow manage access to users who are not associated with a client" do
    @ability.should_not be_able_to( :manage, Factory( :client ) )
  end

  it "should not allow manage access to users who are associated but don't have admin access to a client" do
    client = Factory( :client )
    Factory( :user_role, :user => @user, :manageable => client, :admin => false )

    @ability.should_not be_able_to( :manage, client )
  end

  it "should allow manage access to users who are associated with admin rights to a client" do
    client = Factory( :client )
    Factory( :user_role, :user => @user, :manageable => client, :admin => true )

    @ability.should be_able_to( :manage, client )
  end

  it "should not be able to read finances for a client if not associated with the client" do
    @ability.should_not be_able_to( :read_finances, Factory( :client ) )
  end

  it "should not be able to read finances for a client if finances rights are not given" do
    client = Factory( :client )
    Factory( :user_role, :user => @user, :manageable => client, :finances => false )

    @ability.should_not be_able_to( :read_finances, client )
  end

  it "should be able to read finances for a client if finances rights are given" do
    client = Factory( :client )
    Factory( :user_role, :user => @user, :manageable => client, :finances => true )

    @ability.should be_able_to( :read_finances, client )
  end

  it "should not be able to manage finances for a client if not associated with the client" do
    @ability.should_not be_able_to( :manage_finances, Factory( :client ) )
  end

  it "should not be able to manage finances for a client if finances rights are not given, even if admin rights are" do
    client = Factory( :client )
    Factory( :user_role, :user => @user, :manageable => client, :admin => true )

    @ability.should_not be_able_to( :manage_finances, client )
  end

  it "should not be able to manage finances for a client if admin rights are not given, even if finances rights are" do
    client = Factory( :client )
    Factory( :user_role, :user => @user, :manageable => client, :finances => true )

    @ability.should_not be_able_to( :manage_finances, client )
  end

  it "should be able to manage finances for a client if finances and admin rights are given" do
    client = Factory( :client )
    Factory( :user_role, :user => @user, :manageable => client, :finances => true, :admin => true )

    @ability.should be_able_to( :change_finances, client )
  end

  it "should not allow read access to users who are not associated with a project" do
    @ability.should_not be_able_to( :read, Factory( :project ) )
  end

  it "should allow read access to users who are associated with a project" do
    project = Factory( :project )
    Factory( :user_role, :user => @user, :manageable => project )

    @ability.should be_able_to( :read, project )
  end

  it "should not allow create access on projects to users who are not associated with a client" do
    client = Factory( :client )

    @ability.should_not be_able_to( :create, Factory.build( :project, :client => client ) )
  end

  it "should not allow create access on projects to users who are associated with but don't have admin access to a client" do
    client = Factory( :client )
    Factory( :user_role, :user => @user, :manageable => client, :admin => false )

    @ability.should_not be_able_to( :create, Factory.build( :project, :client => client ) )
  end

  it "should allow create access on projects to users who are associated with admin rights to a client" do
    client = Factory( :client )
    Factory( :user_role, :user => @user, :manageable => client, :admin => true )

    @ability.should be_able_to( :create, Factory.build( :project, :client => client ) )
  end

  it "should not allow manage access to users who are not associated with a project" do
    @ability.should_not be_able_to( :manage, Factory( :project ) )
  end

  it "should not allow manage access to users who are associated but don't have admin access to a project" do
    project = Factory( :project )
    Factory( :user_role, :user => @user, :manageable => project, :admin => false )

    @ability.should_not be_able_to( :manage, project )
  end

  it "should allow manage access to users who are associated with admin rights to a project" do
    project = Factory( :project )
    Factory( :user_role, :user => @user, :manageable => project, :admin => true )

    @ability.should be_able_to( :manage, project )
  end

  it "should not allow read access to users who are not associated with a ticket" do
    @ability.should_not be_able_to( :read, Factory( :ticket ) )
  end

  it "should allow read access to users who are associated with a ticket" do
    ticket = Factory( :ticket )
    Factory( :user_role, :user => @user, :manageable => ticket )

    @ability.should be_able_to( :read, ticket.reload )
  end

  it "should not allow create access on tickets to users who are not associated with a project" do
    project = Factory( :project )

    @ability.should_not be_able_to( :create, Factory.build( :ticket, :project => project ) )
  end

  it "should not allow create access on tickets to users who are associated with but don't have admin access to a project" do
    project = Factory( :project )
    Factory( :user_role, :user => @user, :manageable => project, :admin => false )

    @ability.should_not be_able_to( :create, Factory.build( :ticket, :project => project ) )
  end

  it "should allow create access on tickets to users who are associated with admin rights to a project" do
    project = Factory( :project )
    Factory( :user_role, :user => @user, :manageable => project, :admin => true )

    @ability.should be_able_to( :create, Factory.build( :ticket, :project => project ) )
  end

  it "should not allow manage access to users who are not associated with a ticket" do
    @ability.should_not be_able_to( :manage, Factory( :ticket ) )
  end

  it "should not allow manage access to users who are associated but don't have admin access to a ticket" do
    ticket = Factory( :ticket )
    Factory( :user_role, :user => @user, :manageable => ticket, :admin => false )

    @ability.should_not be_able_to( :manage, ticket )
  end

  it "should allow manage access to users who are associated with admin rights to a ticket" do
    ticket = Factory( :ticket )
    Factory( :user_role, :user => @user, :manageable => ticket, :admin => true )

    @ability.should be_able_to( :manage, ticket.reload )
  end
end

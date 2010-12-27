require 'spec_helper'

describe User do
  it "should validate with valid attributes" do
    Factory.build( :user ).should be_valid
  end

  it "should require an email" do
    user = Factory.build( :user, :email => "" )
    user.save

    user.errors.should eql( :email => ["can't be blank"] )
  end

  it "should require a unique email" do
    Factory( :user, :email => "test@example.com" )
    user = Factory.build( :user, :email => "test@example.com" )
    user.save

    user.errors.should eql( :email => ["has already been taken"] )
  end

  it "should require a username" do
    user = Factory.build( :user, :username => "" )
    user.save

    user.errors.should eql( :username => ["can't be blank"] )
  end

  it "should require a unique username" do
    Factory( :user, :username => "abc" )
    user = Factory.build( :user, :username => "abc" )
    user.save

    user.errors.should eql( :username => ["has already been taken"] )
  end

  it "should require a time zone" do
    user = Factory.build( :user, :time_zone => "" )
    user.save

    user.errors.should eql( :time_zone => ["can't be blank"] )
  end

  it "should not be identified as a worker if it doesn't have anything it's working on" do
    user = Factory( :user )
    user.is_worker?.should be_false
  end

  it "should be identified as a worker if it has anything it's working on" do
    user = Factory( :user )
    user.user_roles << Factory( :user_role, :manageable => Factory( :client ), :worker => true )
    user.is_worker?.should be_true
  end

  it "should return the current workweek" do
    user = Factory( :user )
    old_workweek = Factory( :workweek, :worker => user, :created_at => Time.zone.now - 1.week )
    current_workweek = Factory( :workweek, :worker => user, :created_at => Time.zone.now - 1.hour )
    future_workweek = Factory( :workweek, :worker => user, :created_at => Time.zone.now + 1.day )
    user.current_workweek.should eql( current_workweek )
  end
end

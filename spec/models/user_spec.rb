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

  it "should require a unique username" do
    Factory( :user, :username => "abc" )
    user = Factory.build( :user, :username => "abc" )
    user.save

    user.errors.should eql( :username => ["has already been taken"] )
  end

  it "should allow a valid US time zone" do
    Factory.build( :user, :time_zone => "Mountain Time" ).should be_valid
  end

  it "should not allow an invalid US time zone" do
    user = Factory.build( :user, :time_zone => "Somewhere" )
    user.save

    user.errors.should eql( :time_zone => ["is not included in the list"] )
  end
end

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

  pending "should require a unique username"
  pending "should require a valid US time zone"
end

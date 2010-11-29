require 'spec_helper'

describe UserActivityAlert do
  it "should validate with valid attributes" do
    Factory.build( :user_activity_alert ).should be_valid
  end
end

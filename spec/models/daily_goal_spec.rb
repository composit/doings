require 'spec_helper'

describe DailyGoal do
  it "should validate with valid attributes" do
    Factory.build( :daily_goal ).should be_valid
  end
end

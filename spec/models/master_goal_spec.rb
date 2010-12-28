require 'spec_helper'

describe MasterGoal do
  it "should validate with valid attributes" do
    Factory.build( :master_goal ).should be_valid
  end
end

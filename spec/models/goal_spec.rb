require 'spec_helper'

describe Goal do
  it "should validate with valid attributes" do
    Factory.build( :goal ).should be_valid
  end

  it "should require a name" do
    goal = Factory.build( :goal, :name => nil )
    goal.save

    goal.errors.should eql( :name => ["can't be blank"] )
  end

  it "should require an amount" do
    goal = Factory.build( :goal, :amount => nil )
    goal.save

    goal.errors.should eql( :amount => ["can't be blank", "is not a number"] )
  end

  it "should require a numeric amount" do
    goal = Factory.build( :goal, :amount => "abc" )
    goal.save

    goal.errors.should eql( :amount => ["is not a number"] )
  end

  it "should require a period" do
    goal = Factory.build( :goal, :period => nil )
    goal.save

    goal.errors.should eql( :period => ["can't be blank", "is not included in the list"] )
  end

  it "should require a period from the list" do
    goal = Factory.build( :goal, :period => "abc" )
    goal.save

    goal.errors.should eql( :period => ["is not included in the list"] )
  end

  it "should allow a blank workable" do
    Factory.build( :goal, :workable => nil ).should be_valid
  end

  it "should require a workable_type from the list if set" do
    goal = Factory.build( :goal, :workable_type => "abc" )
    goal.save

    goal.errors.should eql( :workable_type => ["is not included in the list"] )
  end
end

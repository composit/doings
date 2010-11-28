require 'spec_helper'

describe Comment do
  it "should validate with valid attributes" do
    Factory.build( :comment ).should be_valid
  end

  it "should not allow empty content" do
    comment = Factory.build( :comment, :content => "" )
    comment.save
    comment.errors.should eql( :content => ["can't be blank"] )
  end
end

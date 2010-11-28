require 'spec_helper'

describe Invoice do
  it "should validate with valid attributes" do
    Factory.build( :invoice ).should be_valid
  end
end

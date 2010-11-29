require 'spec_helper'

describe UserRole do
  it "should validate with valid attributes" do
    Factory.build( :user_role ).should be_valid
  end
end

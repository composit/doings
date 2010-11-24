require 'spec_helper'

describe Address do
  it "should validate with valid attributes" do
    Factory.build( :address ).should be_valid
  end

  it "should only allow properly formatted zip codes" do
    ["a", "1", "1111", "111111", "aaaaa", "11111-111", "11111-11111", "aaaaa-aaaa", "A11 1AA"].each do |bad_zip|
      address = Factory( :address, :zip => bad_zip )
      address.errors.should eql( "is not allowed" )
    end
    ["11111", "11111-1111", "A1A 1A1"].each do |good_zip|
      address = Factory.build( :address, :zip => good_zip )
      address.should be_valid
    end
  end
end

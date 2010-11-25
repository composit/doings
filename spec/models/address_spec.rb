require 'spec_helper'

describe Address do
  it "should validate with valid attributes" do
    Factory.build( :address ).should be_valid
  end

  it "should allow 5 digit zip codes" do
    address = Factory.build( :address, :zip_code => "11111" )
    address.should be_valid
  end

  it "should not allow zip codes with letters" do
    address = Factory.build( :address, :zip_code => "11a11" )
    address.save

    address.errors.should eql( :zip_code => ["is invalid"] )
  end

  it "should not allow zip codes of less than 5 numbers in the first set" do
    address = Factory.build( :address, :zip_code => "1111" )
    address.save

    address.errors.should eql( :zip_code => ["is invalid"] )
  end

  it "should not allow zip codes of more than 5 numbers in the first set" do
    address = Factory.build( :address, :zip_code => "111111" )
    address.save

    address.errors.should eql( :zip_code => ["is invalid"] )
  end

  it "should allow extended zip codes" do
    address = Factory.build( :address, :zip_code => "11111-1111" )
    address.should be_valid
  end

  it "should not allow extended zip codes with less than 4 numbers in the second set" do
    address = Factory.build( :address, :zip_code => "11111-111" )
    address.save

    address.errors.should eql( :zip_code => ["is invalid"] )
  end

  it "should not allow extended zip codes with more than 4 numbers in the second set" do
    address = Factory.build( :address, :zip_code => "11111-11111" )
    address.save

    address.errors.should eql( :zip_code => ["is invalid"] )
  end

  it "should allow canadian zip codes" do
    address = Factory.build( :address, :zip_code => "A1A 1A1" )
    address.should be_valid
  end

  it "should allow existing states" do
    address = Factory.build( :address, :state => "IL" )
    address.should be_valid end

  it "should allow existing provinces" do
    address = Factory.build( :address, :state => "QC" )
    address.should be_valid
  end

  it "should not allow non-existing states" do
    address = Factory.build( :address, :state => "AA" )
    address.save
    address.errors.should eql( :state => ["is not included in the list"] )
  end

  it "should allow USA as a country" do
    address = Factory.build( :address, :country => "USA" )
    address.should be_valid
  end

  it "should allow Canada as a country" do
    address = Factory.build( :address, :country => "Canada" )
    address.should be_valid
  end

  it "should not allow non-existing countries" do
    address = Factory.build( :address, :country => "Xanadu" )
    address.save
    address.errors.should eql( :country => ["is not included in the list"] )
  end

  it "should allow strangely formatted phone numbers" do
    address = Factory.build( :address, :phone => "1 + (4848) 333-8888 ext. 45" )
    address.should be_valid
  end
end

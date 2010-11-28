require 'spec_helper'

describe OfficeHour do
  it "should validate with valid attributes" do
    Factory.build( :office_hour ).should be_valid
  end

  it "should not allow a day of week outside the range of days" do
    office_hour = Factory.build( :office_hour, :day_of_week => 7 )
    office_hour.save

    office_hour.errors.should eql( :day_of_week => ["is not included in the list"] )
  end

  it "should require a start time" do
    office_hour = Factory.build( :office_hour, :start_time => nil )
    office_hour.save

    office_hour.errors.should eql( :start_time => ["can't be blank"] )
  end

  it "should require an end time" do
    office_hour = Factory.build( :office_hour, :end_time => nil )
    office_hour.save

    office_hour.errors.should eql( :end_time => ["can't be blank"] )
  end
end

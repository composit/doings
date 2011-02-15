require 'spec_helper'

describe Workweek do
  it "should validate with valid attributes" do
    Factory.build( :workweek ).should be_valid
  end

  describe "with a three day workweek" do
    before( :each ) do
      @workweek = Factory( :workweek, :worker => Factory( :user ), :monday => true, :wednesday => true, :saturday => true )
      Timecop.freeze( Time.parse( "2010-10-14" ) )
    end

    after( :each ) do
      Timecop.return
    end

    it "should determine the number of workdays in the day" do
      @workweek.workday_count( :period => "Daily" ).should eql( 0 )
    end

    it "should determine the number of workdays in the week" do
      @workweek.workday_count( :period => "Weekly" ).should eql( 3 )
    end

    it "should determine the number of workdays in the week up to the current day" do
      @workweek.workday_count( :period => "Weekly", :end_time => Time.zone.now ).should eql( 2 )
    end

    it "should determine the number of workdays in the month" do
      @workweek.workday_count( :period => "Monthly" ).should eql( 13 )
    end

    it "should determine the number of workdays in the month up to the current day" do
      @workweek.workday_count( :period => "Monthly", :end_time => Time.zone.now ).should eql( 6 )
    end

    it "should determine the number of workdays in the year" do
      @workweek.workday_count( :period => "Yearly" ).should eql( 156 )
    end

    it "should determine the number of workdays in the year up to the current day" do
      @workweek.workday_count( :period => "Yearly", :end_time => Time.zone.now ).should eql( 123 )
    end
  end

  it "should determine the number of workdays in weeks that wrap to the next year" do
    workweek = Factory( :workweek, :worker => Factory( :user ), :monday => true, :wednesday => true, :saturday => true )
    Timecop.freeze( Time.parse( "2009-12-30" ) )
    workweek.workday_count( :period => "Weekly" ).should eql( 3 )
  end

  it "should determine 1 workday in the day if the day is a workday" do
    workweek = Factory( :workweek, :worker => Factory( :user ), :monday => true, :wednesday => true, :saturday => true )
    Timecop.freeze( Time.parse( "2010-10-13" ) )
    workweek.workday_count( :period => "Daily" ).should eql( 1 )
  end

  describe "when figuring workweeks" do
    before( :each ) do
      @workweek = Factory( :workweek, :worker => Factory( :user ), :monday => true, :wednesday => true, :saturday => true )
      Timecop.freeze( Time.parse( "2010-12-29" ) ) # Wednesday
    end

    after( :each ) do
      Timecop.return
    end

    it "should determine the number of workweeks in the week to be one" do
      @workweek.workday_count( :period => "Weekly", :update_day => 4 ).should eql( 1 )
    end

    it "should determine the number of workweeks in the week up to the current day" do
      @workweek.workday_count( :period => "Weekly", :update_day => 4, :end_time => Time.zone.now ).should eql( 0 )
    end

    it "should determine the number of workweeks in the month" do
      @workweek.workday_count( :period => "Monthly", :update_day => 4 ).should eql( 5 )
    end

    it "should determine the number of workweeks in the month up to the current day" do
      @workweek.workday_count( :period => "Monthly", :update_day => 4, :end_time => Time.zone.now ).should eql( 4 )
    end

    it "should determine the number of workweeks in the year" do
      @workweek.workday_count( :period => "Yearly", :update_day => 4 ).should eql( 52 )
    end

    it "should determine the number of workweeks in the year up to the current day" do
      @workweek.workday_count( :period => "Yearly", :update_day => 4, :end_time => Time.zone.now ).should eql( 51 )
    end
  end

  it "should return the number of workdays" do
    Factory( :weekday_workweek, :worker => Factory( :user ) ).number_of_workdays.should eql( 5 )
  end
end

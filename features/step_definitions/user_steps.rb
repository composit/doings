Given /^I log in as "([^"]*)"$/ do |username|
  visit destroy_user_session_path
  user = User.find_by_username( username ) || Factory( :confirmed_user, :username => username )
  visit new_user_session_path
  fill_in( 'Username', :with => username )
  fill_in( 'Password', :with => 'testpass' )
  click_button( 'Sign in' )
end

Then /^the time zone should be "([^"]*)"$/ do |time_zone|
  Time.zone.to_s.should eql( time_zone )
end

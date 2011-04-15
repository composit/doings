Given /^the following goals:$/ do |table|
  table.hashes.each do |hash|
    hash["user"] = User.find_by_username( hash.delete( "user_username" ) ) if( hash["user_username"] )
    hash["weekday"] = Time.zone.now.wday if( hash.delete( "relative_weekday" ) == "today" )
    Factory( :goal, hash )
  end
end

When /^I follow "([^"]*)" for the "([^"]*)" goal$/ do |link, goal_name|
  goal = Goal.find_by_name( goal_name )
  with_scope( "\"#goal-#{goal.id}\"" ) do
    click_link( link )
  end
end

When /^I fill in "([^"]*)" for the "([^"]*)" goal priority$/ do |priority, goal_name|
  goal = Goal.find_by_name( goal_name )
  fill_in( "goal_priorities_#{goal.id}_new", :with => priority )
end

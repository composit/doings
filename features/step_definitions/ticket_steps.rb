Given /^the following tickets:$/ do |table|
  table.hashes.each do |hash|
    hash["project"] = Project.find_by_name( hash.delete( "project_name" ) ) if( hash["project_name"] )
    Factory( :ticket, hash )
  end
end

When /^I follow "([^"]*)" for the "([^"]*)" ticket$/ do |link, ticket_name|
  ticket = Ticket.find_by_name( ticket_name )
  with_scope( "#ticket-#{ticket.id}" ) do
    click_link( link )
  end
end

When /^I check "([^"]*)" in the roles for "([^"]*)"$/ do |role, username|
  page.find( ".user-role", :text => username ).check( role )
end

When /^I uncheck "([^"]*)" in the roles for "([^"]*)"$/ do |role, username|
  page.find( ".user-role", :text => username ).uncheck( role )
end

Then /^"([^"]*)" should have the "([^"]*)" role for the "([^"]*)" ticket$/ do |username, role_name, ticket_name|
  user = User.find_by_username( username )
  ticket = Ticket.find_by_name( ticket_name )
  eval( "user.user_roles.where( :manageable_id => ticket.id, :manageable_type => 'Ticket' ).first.#{role_name}" ).should be_true
end

Then /^"([^"]*)" should not have the "([^"]*)" role for the "([^"]*)" ticket$/ do |username, role_name, ticket_name|
  user = User.find_by_username( username )
  ticket = Ticket.find_by_name( ticket_name )
  eval( "user.user_roles.where( :manageable_id => ticket.id, :manageable_type => 'Ticket' ).first.#{role_name}" ).should be_false
end

Then /^the "([^"]*)" checkbox in the roles for "([^"]*)" should be checked$/ do |role, username|
  page.find( ".user-role", :text => username ).find_field( role )['checked'].should be_true
end

Then /^the "([^"]*)" checkbox in the roles for "([^"]*)" should not be checked$/ do |role, username|
  page.find( ".user-role", :text => username ).find_field( role )['checked'].should be_false
end

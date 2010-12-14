Given /^the following user roles:$/ do |table|
  table.hashes.each do |hash|
    hash["user"] = User.find_by_username( hash.delete( "user_username" ) ) if( hash["user_username"] )
    hash["manageable"] = Client.find_by_name( hash.delete( "client_name" ) ) if( hash["client_name"] )
    hash["manageable"] = Project.find_by_name( hash.delete( "project_name" ) ) if( hash["project_name"] )
    hash["manageable"] = Ticket.find_by_name( hash.delete( "ticket_name" ) ) if( hash["ticket_name"] )
    Factory( :user_role, hash )
  end
end

When /^I check "([^"]*)" in the roles for "([^"]*)"$/ do |role, username|
  page.find( ".user-role", :text => username ).check( role )
end

When /^I uncheck "([^"]*)" in the roles for "([^"]*)"$/ do |role, username|
  page.find( ".user-role", :text => username ).uncheck( role )
end

Then /^the following roles should be set:$/ do |table|
  table.hashes.each do |hash|
    user = User.find_by_username( hash["user_username"] )
    manageable = Ticket.find_by_name( hash["ticket_name"] ) if( hash["ticket_name"] )
    manageable = Project.find_by_name( hash["project_name"] ) if( hash["project_name"] )
    roles = {}
    roles[:admin] = hash["admin"] if( hash["admin"] )
    roles[:worker] = hash["worker"] if( hash["worker"] )
    user.user_roles.where( { :manageable_id => manageable.id, :manageable_type => manageable.class.name }.merge( roles ) ).length.should eql( 1 )
  end
end

Then /^the "([^"]*)" checkbox in the roles for "([^"]*)" should be checked$/ do |role, username|
  page.find( ".user-role", :text => username ).find_field( role )['checked'].should be_true
end

Then /^the "([^"]*)" checkbox in the roles for "([^"]*)" should not be checked$/ do |role, username|
  page.find( ".user-role", :text => username ).find_field( role )['checked'].should be_false
end

Then /^the "([^"]*)" checkbox in the roles for "([^"]*)" should be disabled$/ do |role, username|
  page.find( ".user-role", :text => username ).find_field( role )['disabled'].should eql( "true" )
end

Then /^the "([^"]*)" checkbox in the roles for "([^"]*)" should not be disabled$/ do |role, username|
  page.find( ".user-role", :text => username ).find_field( role )['disabled'].should eql( "false" )
end

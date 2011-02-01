When /^the following projects:$/ do |table|
  table.hashes.each do |hash|
    hash["client"] = Client.find_by_name( hash.delete( "client_name" ) ) if( hash["client_name"] )
    Factory( :project, hash )
  end
end

When /^I follow "([^"]*)" for the "([^"]*)" client$/ do |link, client_name|
  client = Client.find_by_name( client_name )
  scope = "#client-#{client.id}"
  with_scope( scope ) do
    click_link( link )
  end
end

When /^I follow "([^"]*)" for the "([^"]*)" project$/ do |link, project_name|
  project = Project.find_by_name( project_name )
  with_scope( "#project-#{project.id}" ) do
    click_link( link )
  end
end

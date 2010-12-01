When /^the following projects:$/ do |table|
  table.hashes.each do |hash|
    hash["client"] = Client.find_by_name( hash.delete( "client_name" ) ) if( hash["client_name"] )
    Factory( :project, hash )
  end
end

When /^I follow "([^"]*)" for the "([^"]*)" client$/ do |link, client_name|
  if( client_name == "All clients" )
    scope = "#client-all"
  else
    client = Client.find_by_name( client_name )
    scope = "#client-#{client.id}"
  end
  with_scope( scope ) do
    click_link( link )
  end
end

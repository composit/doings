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

Given /^the following tickets:$/ do |table|
  table.hashes.each do |hash|
    hash["project"] = Project.find_by_name( hash.delete( "project_name" ) ) if( hash["project_name"] )
    Factory( :ticket, hash )
  end
end

Given /^all tickets for "([^"]*)" are closed$/ do |username|
  User.find_by_username( username ).tickets.each do |ticket|
    ticket.update_attributes!( :closed_at => Time.zone.now )
  end
end

When /^I follow "([^"]*)" for the "([^"]*)" ticket$/ do |link, ticket_name|
  ticket = Ticket.find_by_name( ticket_name )
  with_scope( "#ticket-#{ticket.id}" ) do
    click_link( link )
  end
end

When /^I fill in "([^"]*)" for the "([^"]*)" ticket priority$/ do |priority, ticket_name|
  ticket = Ticket.find_by_name( ticket_name )
  fill_in( "ticket_priorities_#{ticket.id}_new", :with => priority )
end

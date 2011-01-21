Given /^the following billing rates:$/ do |table|
  table.hashes.each do |hash|
    biller = Client.find_by_name( hash.delete( "client_name" ) ) if( hash["client_name"] )
    biller = Project.find_by_name( hash.delete( "project_name" ) ) if( hash["project_name"] )
    biller = Ticket.find_by_name( hash.delete( "ticket_name" ) ) if( hash["ticket_name"] )
    hash["billable"] = Client.find_by_name( hash.delete( "billable_client_name" ) ) if( hash["billable_client_name"] )
    hash["billable"] = Project.find_by_name( hash.delete( "billable_project_name" ) ) if( hash["billable_project_name"] )
    hash["billable"] = Ticket.find_by_name( hash.delete( "billable_ticket_name" ) ) if( hash["billable_ticket_name"] )
    biller.billing_rate.update_attributes!( hash )
  end
end

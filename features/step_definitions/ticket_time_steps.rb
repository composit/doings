Given /^the following ticket times:$/ do |table|
  table.hashes.each do |hash|
    hash["worker"] = User.find_by_username( hash.delete( "worker_username" ) ) if( hash["worker_username"] )
    hash["ticket"] = Ticket.find_by_name( hash.delete( "ticket_name" ) ) if( hash["ticket_name"] )
    Factory( :ticket_time, hash )
  end
end

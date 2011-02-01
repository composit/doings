Given /^the following ticket times:$/ do |table|
  table.hashes.each do |hash|
    hash["worker"] = User.find_by_username( hash.delete( "worker_username" ) ) if( hash["worker_username"] )
    hash["ticket"] = Ticket.find_by_name( hash.delete( "ticket_name" ) ) if( hash["ticket_name"] )
    hash["started_at"] = hash.delete( "started_at_minutes_ago" ).to_i.minutes.ago if( hash["started_at_minutes_ago"] )
    hash["ended_at"] = hash.delete( "ended_at_minutes_ago" ).to_i.minutes.ago if( hash["ended_at_minutes_ago"] )
    hash["invoice"] = Invoice.find_by_description( hash.delete( "invoice_description" ) ) if( hash["invoice_description"] )
    Factory( :ticket_time, hash )
  end
end

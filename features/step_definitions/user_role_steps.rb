Given /^the following user roles:$/ do |table|
  table.hashes.each do |hash|
    hash["user"] = User.find_by_username( hash.delete( "user_username" ) ) if( hash["user_username"] )
    hash["manageable"] = Client.find_by_name( hash.delete( "client_name" ) ) if( hash["client_name"] )
    hash["manageable"] = Project.find_by_name( hash.delete( "project_name" ) ) if( hash["project_name"] )
    hash["manageable"] = Ticket.find_by_name( hash.delete( "ticket_name" ) ) if( hash["ticket_name"] )
    Factory( :user_role, hash )
  end
end
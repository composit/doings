Given /^the following billing rates:$/ do |table|
  table.hashes.each do |hash|
    billable = Client.find_by_name( hash.delete( "client_name" ) ) if( hash["client_name"] )
    billable = Project.find_by_name( hash.delete( "project_name" ) ) if( hash["project_name"] )
    billable.billing_rate.update_attributes!( hash )
  end
end

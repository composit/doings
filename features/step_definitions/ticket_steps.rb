Given /^the following tickets:$/ do |table|
  table.hashes.each do |hash|
    hash["project"] = Project.find_by_name( hash.delete( "project_name" ) ) if( hash["project_name"] )
    Factory( :ticket, hash )
  end
end

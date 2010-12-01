Given /^the following clients:$/ do |table|
  table.hashes.each do |hash|
    hash.address = {}
    hash.address.merge!( :state => hash.delete( "address_state" ) ) if( hash["address_state"] )
    Factory( :client, hash )
  end
end

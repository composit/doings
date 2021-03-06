Given /^the following user activity alerts:$/ do |table|
  table.hashes.each do |hash|
    hash["user"] = User.find_by_username( hash.delete( "user_username" ) ) if( hash["user_username"] )
    Factory( :user_activity_alert, hash )
  end
end

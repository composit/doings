Given /^the following goals:$/ do |table|
  table.hashes.each do |hash|
    hash["user"] = User.find_by_username( hash.delete( "user_username" ) ) if( hash["user_username"] )
    hash["weekday"] = Time.zone.now.wday if( hash.delete( "relative_weekday" ) == "today" )
    Factory( :goal, hash )
  end
end

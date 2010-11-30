Factory.define( :user ) do |u|
  u.sequence( :email ) { |n| "abc#{n}@example.com" }
  u.sequence( :username ) { |n| "abc#{n}" }
  u.password "testpass"
  u.password_confirmation "testpass"
  u.time_zone "Mountain Time (US & Canada)"
end

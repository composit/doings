Factory.define( :user ) do |u|
  u.sequence( :email ) { |n| "abc#{n}@example.com" }
  u.sequence( :username ) { |n| "abc#{n}" }
  u.password "testpass"
  u.password_confirmation "testpass"
  u.time_zone "Mountain Time (US & Canada)"
end

Factory.define( :confirmed_user, :parent => :user ) do |c|
  c.confirmed_at Time.zone.now
end

Factory.define( :worker, :parent => :confirmed_user ) do |w|
  w.after_create do |worker|
    ticket = Factory( :ticket )
    worker.user_roles << UserRole.create!( :user => worker, :manageable => ticket, :worker => true )
  end
end

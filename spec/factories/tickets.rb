Factory.define( :ticket ) do |t|
  t.sequence( :name ) { |n| "abc#{n}" }
  t.created_by_user { |a| a.association :user }
end

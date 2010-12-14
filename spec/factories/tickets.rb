Factory.define( :ticket ) do |t|
  t.sequence( :name ) { |n| "abc#{n}" }
  t.created_by_user { |a| a.association :user }
  t.billing_rate { |a| a.association :billing_rate }
end

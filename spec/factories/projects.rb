Factory.define( :project ) do |p|
  p.sequence( :name ) { |n| "abc#{n}" }
  p.created_by_user { |a| a.association :user }
  p.billing_rate { |a| a.association :billing_rate }
end

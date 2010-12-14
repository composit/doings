Factory.define( :client ) do |c|
  c.sequence( :name ) { |n| "abc#{n}" }
  c.billing_rate { |a| a.association :billing_rate }
end

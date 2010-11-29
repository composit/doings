Factory.define( :ticket ) do |t|
  t.sequence( :name ) { |n| "abc#{n}" }
end

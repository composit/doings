Factory.define( :client ) do |c|
  c.sequence( :name ) { |n| "abc#{n}" }
end

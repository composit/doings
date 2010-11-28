Factory.define( :project ) do |p|
  p.sequence( :name ) { |n| "abc#{n}" }
end

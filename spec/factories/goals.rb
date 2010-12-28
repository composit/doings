Factory.define( :goal ) do |g|
  g.name "abc"
  g.amount 123
  g.period Goal::PERIODS.first
  g.units Goal::UNITS.first
end

Factory.define( :master_goal, :parent => :goal ) do |m|
end

Factory.define( :daily_goal, :parent => :goal ) do |d|
end

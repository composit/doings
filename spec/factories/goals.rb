Factory.define( :goal ) do |g|
  g.name "abc"
  g.amount 123
  g.period Goal::PERIODS.first
end

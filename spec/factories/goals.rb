Factory.define( :goal ) do |g|
  g.name "abc"
  g.amount 123
  g.period Goal::PERIODS.first
  g.units Goal::UNITS.first
  g.user { |a| a.association( :worker ) }
end

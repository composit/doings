Factory.define( :goal ) do |g|
  g.name "abc"
  g.amount 123
  g.period Goal::PERIOD_OPTIONS.first
  g.units Goal::UNIT_OPTIONS.first
  g.user { |a| a.association( :worker ) }
end

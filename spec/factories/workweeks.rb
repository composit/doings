Factory.define( :workweek ) do |w|
end

Factory.define( :weekday_workweek, :parent => :workweek ) do |w|
  w.monday true
  w.tuesday true
  w.wednesday true
  w.thursday true
  w.friday true
end

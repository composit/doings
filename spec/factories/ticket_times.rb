Factory.define( :ticket_time ) do |t|
  t.worker { |a| a.association( :user ) }
end

Factory.define( :ticket_time ) do |t|
  t.worker { |a| a.association( :user ) }
  t.ticket { |a| a.association( :ticket ) }
end

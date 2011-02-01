Factory.define( :invoice ) do |i|
  i.client { |a| a.association( :client ) }
end

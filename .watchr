#watch( 'spec/models/.*_spec\.rb' ) { |md| system( "rspec #{md[0]}" ) }
watch( '.*' ) { |md| system( "rspec spec/models/ticket_spec.rb" ) }
#watch( '.*' ) { |md| system( "cucumber features/manage_tickets.feature --tags @current" ) }

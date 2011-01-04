watch( 'spec/models/.*_spec\.rb' ) { |md| system( "rspec #{md[0]}" ) }

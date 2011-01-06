#watch( 'spec/models/.*_spec\.rb' ) { |md| system( "rspec #{md[0]}" ) }
watch( '.*' ) { |md| system( "rspec spec/models/user_spec.rb:122" ) }
#watch( '.*' ) { |md| system( "cucumber features/manage_goals.feature --tags @current" ) }

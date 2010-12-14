module ProjectsHelper
  def generate_new_ticket( project )
    ( @ticket && !@ticket.errors.empty? ) ? @ticket : project.build_inherited_ticket( current_user.id )
  end
end

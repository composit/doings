module ProjectsHelper
  def generate_new_ticket( project )
    ( @ticket && !@ticket.errors.empty? ) ? @ticket : project.build_ticket_with_inherited_roles( current_user.id )
  end
end

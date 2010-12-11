module ProjectsHelper
  def generate_new_ticket( project )
    @ticket || project.build_ticket_with_inherited_roles
  end
end

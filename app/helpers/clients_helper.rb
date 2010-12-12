module ClientsHelper
  def generate_new_project( client )
    #( @project && !@project.errors.empty? ) ? @project : client.build_project_with_inherited_roles( current_user.id )
    client.build_project_with_inherited_roles( current_user.id )
  end
end

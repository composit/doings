module ClientsHelper
  def generate_new_project( client )
    client.build_project_with_inherited_roles( current_user.id )
  end
end

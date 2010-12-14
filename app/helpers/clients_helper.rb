module ClientsHelper
  def generate_new_project( client )
    client.build_inherited_project( current_user.id )
  end
end

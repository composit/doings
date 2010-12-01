class ProjectsController < ApplicationController
  def index
    @projects = current_user.projects
    @projects = @projects.where( :client_id => params[:client_id] ) if( params[:client_id] )
  end
end

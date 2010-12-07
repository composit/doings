class ProjectsController < ApplicationController
  load_and_authorize_resource

  respond_to :js, :only => :show
  respond_to :html, :only => :index

  def index
    #@projects = current_user.projects
    @projects = @projects.where( :client_id => params[:client_id] ) if( params[:client_id] )
  end

  def show
  end
end

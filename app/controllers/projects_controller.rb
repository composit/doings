class ProjectsController < ApplicationController
  load_and_authorize_resource

  respond_to :js, :only => [:show, :create, :workables]
  respond_to :html, :only => :index

  def index
    if( params[:client_id] )
      @client = Client.find( params[:client_id] )
      @projects = @projects.where( :client_id => @client.id )
    end
  end

  def show
  end

  def create
    @project.save
    respond_with( @project )
  end

  def workables
    @workables = Project.includes( :user_roles ).where( :user_roles => { :user_id => current_user.id, :worker => true }, :closed_at => nil )
    render( "/shared/workables" )
  end
end

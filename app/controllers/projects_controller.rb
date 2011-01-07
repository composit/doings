class ProjectsController < ApplicationController
  load_and_authorize_resource

  respond_to :js, :only => [:show, :edit, :update, :create, :workables]
  respond_to :html, :only => :index

  def index
    @client = Client.find( params[:client_id] )
    @projects = @projects.where( :client_id => @client.id )
  end

  def show
  end

  def create
    @project.save
    respond_with( @project )
  end

  def edit
  end

  def update
    @project.update_attributes( params[:project] )
    respond_with( @project )
  end

  def workables
    @workables = Project.includes( :user_roles ).where( :user_roles => { :user_id => current_user.id, :worker => true }, :closed_at => nil )
    render( "/shared/workables" )
  end
end

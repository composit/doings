class ProjectsController < ApplicationController
  load_and_authorize_resource

  respond_to :js, :only => [:show, :edit, :update, :create, :workables]
  respond_to :html, :only => :index

  def index
    @client = Client.find( params[:client_id] )
    @projects = @client.projects.where( :closed_at => nil ).accessible_by( current_ability )
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
    @workables = Project.accessible_by( current_ability, :workables )
    render( "/shared/workables" )
  end
end

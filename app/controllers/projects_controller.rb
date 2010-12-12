class ProjectsController < ApplicationController
  load_and_authorize_resource

  respond_to :js, :only => [:show, :create]
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
end

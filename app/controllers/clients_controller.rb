class ClientsController < ApplicationController
  respond_to :html, :only => [:show, :new, :create, :update]
  respond_to :js, :only => [:index, :workables]

  load_and_authorize_resource

  def show
    @client.address ||= Address.new
  end

  def new
    @client.address = Address.new
    @client.user_roles << UserRole.new( :user => current_user, :manageable => @client )
  end

  def create
    @client.save
    respond_with( @client )
  end

  def update
    flash[:notice] = 'Client was successfully updated' if( @client.update_attributes( params[:client] ) )
    respond_with( @client )
  end

  def workables
    @workables = Client.includes( :user_roles ).where( :user_roles => { :user_id => current_user.id, :worker => true } )
    render( "/shared/workables" )
  end
end

class ClientsController < ApplicationController
  respond_to :html, :only => [:edit, :new, :create, :update]
  respond_to :js, :only => [:index, :workables]

  self.responder = DoingsResponder
  load_and_authorize_resource

  def show
  end

  def new
    @client.address = Address.new
    @client.user_roles << UserRole.new( :user => current_user, :manageable => @client, :admin => true )
    @client.billing_rate = BillingRate.new
    @client.created_by_user_id = current_user.id
  end

  def create
    flash[:notice] = 'Client was successfully created' if( @client.save )
    respond_with( @client )
  end

  def edit
    @client.address ||= Address.new
  end

  def update
    flash[:notice] = 'Client was successfully updated' if( @client.update_attributes( params[:client] ) )
    respond_with( @client )
  end

  def workables
    @workables = Client.accessible_by( current_ability, :workables )
    render( "/shared/workables" )
  end
end

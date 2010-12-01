class ClientsController < ApplicationController
  respond_to :html

  load_and_authorize_resource

  def show
    @client.address ||= Address.new
  end

  def new
    @client.address = Address.new
  end

  def update
    flash[:notice] = 'Client was successfully updated' if( @client.update_attributes( params[:client] ) )
    respond_with( @client )
  end

  private
    def build_address
      @client
    end
end

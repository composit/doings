class InvoicesController < ApplicationController
  respond_to :html, :only => [:index, :show]

  load_and_authorize_resource

  def index
    @client = Client.find( params[:client_id] )
    @invoices = @client.invoices.accessible_by( current_ability )
  end

  def show
  end
end

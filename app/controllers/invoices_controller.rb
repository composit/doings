class InvoicesController < ApplicationController
  respond_to :html, :only => [:index, :show, :new]

  load_and_authorize_resource
  skip_load_and_authorize_resource :only => :new

  def index
    @client = Client.find( params[:client_id] )
    @invoices = @client.invoices.accessible_by( current_ability )
  end

  def show
  end

  def new
    @client = Client.find( params[:client_id] )
    @invoice = @client.invoices.build
    authorize! :create, @invoice
  end

  def create
    flash[:notice] = 'Invoice was successfully created' if( @invoice.save )
    redirect_to @invoice
  end

  def edit
  end

  def update
  end

  def destroy
  end
end

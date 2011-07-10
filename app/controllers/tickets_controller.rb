class TicketsController < ApplicationController
  self.responder = DoingsResponder
  respond_to :html, :only => :index
  respond_to :js, :only => [:show, :create, :edit, :update, :workables]

  load_and_authorize_resource

  def index
    @tickets = @tickets.includes( :user_roles ).where( :closed_at => nil ).order( :priority )
  end

  def show
  end

  def create
    @ticket.save
    respond_with( @ticket )
  end

  def edit
  end

  def update
    @ticket.update_attributes( params[:ticket] )
    respond_with( @ticket )
  end

  def workables
    @workables = Ticket.accessible_by( current_ability, :workables )
    render( "/shared/workables" )
  end

  def prioritize
    Ticket.reprioritize!( current_user, params[:ticket_priorities] )
    redirect_to tickets_url
  end
end

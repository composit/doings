class TicketsController < ApplicationController
  respond_to :js

  load_and_authorize_resource

  def create
    @ticket.save
    respond_with( @ticket )
  end

  def workables
    @workables = Ticket.includes( :user_roles ).where( :user_roles => { :user_id => current_user.id, :worker => true }, :closed_at => nil )
    render( "/shared/workables" )
  end
end

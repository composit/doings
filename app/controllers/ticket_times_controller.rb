class TicketTimesController < ApplicationController
  respond_to :js

  load_and_authorize_resource

  def create
    @ticket_time.save
    respond_with( @ticket_time )
  end

  def update
    @ticket_time.update_attributes( params[:ticket_time] )
    respond_with( @ticket_time )
  end
end

class TicketsController < ApplicationController
  respond_to :js

  load_and_authorize_resource

  def create
    @ticket.save
    respond_with( @ticket )
  end
end

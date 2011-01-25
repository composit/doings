class TicketTimesController < ApplicationController
  respond_to :js, :only => [:create, :update]
  respond_to :html, :only => [:index, :edit, :update]

  load_and_authorize_resource

  def index
    @ticket_times = @ticket_times.paginate( :page => params[:page], :order => "started_at desc" )
  end

  def create
    @ticket_time.save
    respond_with( @ticket_time )
  end

  def edit
  end

  def update
    @ticket_time.update_attributes( params[:ticket_time] )
    respond_with( @ticket_time )
  end
end

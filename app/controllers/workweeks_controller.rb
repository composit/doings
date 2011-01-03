class WorkweeksController < ApplicationController
  respond_to :html, :only => :create

  load_and_authorize_resource

  def create
    flash[:notice] = "Workweek updated" if( @workweek.save! )
    redirect_to( goals_path )
  end
end

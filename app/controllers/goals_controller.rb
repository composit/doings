class GoalsController < ApplicationController
  respond_to :html, :only => :index
  respond_to :js, :only => :create

  load_and_authorize_resource

  def index
  end

  def create
    @goal.save
    respond_with( @goal )
  end
end

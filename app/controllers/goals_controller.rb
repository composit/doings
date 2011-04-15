class GoalsController < ApplicationController
  respond_to :html, :only => [:index, :prioritize]
  respond_to :js, :only => [:create, :destroy]

  self.responder = DoingsResponder
  load_and_authorize_resource

  def index
    @goals = @goals.order( :priority )
  end

  def create
    @goal.save
    respond_with( @goal )
  end

  def destroy
    @goal.destroy
  end

  def prioritize
    Goal.reprioritize!( params[:goal_priorities] )
    redirect_to goals_url
  end
end

class PanelController < ApplicationController

  self.responder = DoingsResponder

  def index
    @daily_goals = current_user.daily_goals!
  end
end

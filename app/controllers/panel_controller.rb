class PanelController < ApplicationController
  def index
    @daily_goals = current_user.daily_goals!
  end
end

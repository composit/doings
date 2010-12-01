class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_user_time_zone
  before_filter :authenticate_user!

  self.responder = DoingsResponder

  private
    def set_user_time_zone
      Time.zone = current_user.time_zone if( user_signed_in? )
    end
end

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :set_user_time_zone
  before_filter :set_nav_clients

  self.responder = DoingsResponder

  private
    def set_user_time_zone
      Time.zone = current_user.time_zone if( user_signed_in? )
    end

    def set_nav_clients
      @nav_clients = Client.accessible_by( current_ability ) if( current_user )
    end
end

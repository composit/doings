require 'doings_responder'

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :set_user_time_zone
  before_filter :set_layout_defaults
  before_filter :set_responder, :unless => Proc.new { devise_controller? }

  private
    def set_user_time_zone
      Time.zone = current_user.time_zone if( user_signed_in? )
    end

    def set_layout_defaults
      if( current_user )
        @nav_clients = Client.accessible_by( current_ability ).order( :name )
        @current_ticket_time = current_user.ticket_times.where( :ended_at => nil ).first
      end
    end

    def set_responder
      self.responder = DoingsResponder
    end
end

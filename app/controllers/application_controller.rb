class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_user_time_zone

  def after_sign_in_path_for( user )
    if( user.is_worker )
      current_tickets_url
    else
      super
    end
  end

  private
    def set_user_time_zone
      Time.zone = current_user.time_zone if( user_signed_in? )
    end
end

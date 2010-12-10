class DoingsResponder < ActionController::Responder
  def to_html
    if( get? )
      render
    elsif( has_errors? )
      render( :action => ( post? ? :new : :show ) )
    else
      redirect_to( :action => :show, :id => resource.id )
    end
  end

  def to_js
    [:notice, :alert].each do |message_type|
      controller.flash.now[message_type] = controller.flash.delete( message_type )
    end
    if( get? )
      render
    elsif( has_errors? )
      render( :action => ( post? ? :new : :edit ) )
    else
      render( :action => :edit )
    end
  end
end
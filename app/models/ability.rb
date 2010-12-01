class Ability
  include CanCan::Ability

  def initialize( user )
    can :read, Client do |client|
      user.can_view?( client )
    end
    can :manage, Client do |client|
      user.is_admin_for?( client )
    end
  end
end

class Ability
  include CanCan::Ability

  def initialize( user )
    can :read, Client, :user_roles => { :user_id => user.id }
    can :manage, Client, :user_roles => { :user_id => user.id, :admin => true }
    can :read, Project, :user_roles => { :user_id => user.id }
  end
end

class Ability
  include CanCan::Ability

  def initialize( user )
    can :read, Client, :user_roles => { :user_id => user.id }
    can :manage, Client, :user_roles => { :user_id => user.id, :admin => true }

    can :read, Project, :user_roles => { :user_id => user.id }
    can :manage, Project, :user_roles => { :user_id => user.id, :admin => true }

    can :read, Ticket, :user_roles => { :user_id => user.id }
    can :create, Ticket, :project => { :user_roles => { :user_id => user.id, :admin => true } }
    can :manage, Ticket, :user_roles => { :user_id => user.id, :admin => true }

    can [:read, :update, :destroy], TicketTime, :worker_id => user.id
    can :create, TicketTime, :ticket => { :user_roles => { :user_id => user.id, :worker => true } }
  end
end

class Ability
  include CanCan::Ability

  def initialize( user )
    can :read, Client, :user_roles => { :user_id => user.id }
    can :create, Client
    can :update, Client, :user_roles => { :user_id => user.id, :admin => true }
    can :read_finances, Client, :user_roles => { :user_id => user.id, :finances => true }
    can :workables, Client, :active => true, :user_roles => { :user_id => user.id, :worker => true }
    can :manage_finances, Client, :user_roles => { :user_id => user.id, :finances => true, :admin => true }

    can :read, Project, :user_roles => { :user_id => user.id }
    can :create, Project, :client => { :user_roles => { :user_id => user.id, :admin => true } }
    can :update, Project, :user_roles => { :user_id => user.id, :admin => true }
    can :workables, Project, :closed_at => nil, :user_roles => { :user_id => user.id, :worker => true }
    can :read_finances, Project, :user_roles => { :user_id => user.id, :finances => true }
    can :manage_finances, Project, :user_roles => { :user_id => user.id, :finances => true, :admin => true }

    can :read, Ticket, :user_roles => { :user_id => user.id }
    can :create, Ticket, :project => { :user_roles => { :user_id => user.id, :admin => true } }
    can :update, Ticket, :user_roles => { :user_id => user.id, :admin => true }
    can [:workables, :prioritize], Ticket, :closed_at => nil, :user_roles => { :user_id => user.id, :worker => true }
    can :read_finances, Ticket, :user_roles => { :user_id => user.id, :finances => true }
    can :manage_finances, Ticket, :user_roles => { :user_id => user.id, :finances => true, :admin => true }

    can [:read, :update, :destroy], TicketTime, :worker_id => user.id
    can :create, TicketTime, :ticket => { :user_roles => { :user_id => user.id, :worker => true } }

    can :manage, Goal, :user_id => user.id

    can :manage, Workweek, :worker_id => user.id
  end
end

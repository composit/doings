class Ability
  include CanCan::Ability

  def initialize( user )
    can :read, Client, :user_roles => { :user_id => user.id }
    can :create, Client
    can :manage, Client, :user_roles => { :user_id => user.id, :admin => true }
    can :read_finances, Client, :user_roles => { :user_id => user.id, :finances => true }
    #can :manage_finances, Client, :user_roles => { :user_id => user.id, :finances => true, :admin => true }

    can :read, Project, :user_roles => { :user_id => user.id }
    can :create, Project, :client => { :user_roles => { :user_id => user.id, :admin => true } }
    can :manage, Project, :user_roles => { :user_id => user.id, :admin => true }
    #can :read_finances, Project, :user_roles => { :user_id => user.id, :finances => true }
    #can :manage_finances, Project, :user_roles => { :user_id => user.id, :finances => true, :admin => true }
    #can :manage_finances, Project, :id => 100

    can :read, Ticket, :user_roles => { :user_id => user.id }
    can :create, Ticket, :project => { :user_roles => { :user_id => user.id, :admin => true } }
    can :manage, Ticket, :user_roles => { :user_id => user.id, :admin => true }
    #can :read_finances, Ticket, :user_roles => { :user_id => user.id, :finances => true }
    #can :manage_finances, Ticket, :user_roles => { :user_id => user.id, :finances => true, :admin => true }

    can [:read, :update, :destroy], TicketTime, :worker_id => user.id
    can :create, TicketTime, :ticket => { :user_roles => { :user_id => user.id, :worker => true } }

    can :manage, Goal, :user_id => user.id

    can :manage, Workweek, :worker_id => user.id
  end
end

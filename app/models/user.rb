class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

  has_many :comments, :as => :commenter
  has_many :invoices, :as => :created_by_user
  has_many :office_hours, :as => :worker
  has_many :created_projects, :class_name => 'Project', :as => :created_by_user
  has_many :closed_projects, :class_name => 'Project', :as => :closed_by_user
  has_many :authorized_projects, :class_name => 'Project', :as => :authorized_by_user
  has_many :ticket_times, :foreign_key => :worker_id
  has_many :created_tickets, :class_name => 'Ticket', :as => :created_by_user
  has_many :user_roles
  has_many :clients, :through => :user_roles, :source => :manageable, :source_type => 'Client'
  has_many :projects, :through => :user_roles, :source => :manageable, :source_type => 'Project'
  has_many :tickets, :through => :user_roles, :source => :manageable, :source_type => 'Ticket'
  has_many :user_activity_alerts
  has_many :goals
  has_many :workweeks, :foreign_key => :worker_id

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :time_zone

  validates :username, :uniqueness => true, :presence => true
  validates :time_zone, :presence => true

  def is_worker?
    user_roles.where( :worker => true ).count > 0
  end

  def current_workweek( time = Time.zone.now )
    workweeks.order( "created_at desc, id desc" ).where( "created_at <= ?", time ).first
  end

  def daily_goals!
    goals.each do |goal|
      # update the daily values
      goal.save! if( goal.daily_date.nil? || goal.daily_date < Time.zone.now.to_date )
    end
  end

  def daily_percentage_complete
    minutes_percentage = daily_percentage( "minutes" )
    dollars_percentage = daily_percentage( "dollars" )
    if( dollars_percentage == 0 )
      ( minutes_percentage * 100 ).round
    elsif( minutes_percentage == 0 )
      ( dollars_percentage * 100 ).round
    else
      ( ( minutes_percentage + dollars_percentage ) * 50 ).round
    end
  end

  def best_available_ticket
    goals.order( :priority ).each do |goal|
      return goal.best_available_ticket if( goal.best_available_ticket )
    end
    return tickets.where( :closed_at => nil ).order( :priority ).first
  end

  private
    def daily_percentage( units )
      goal_array = goals.where( :units => units ).inject( [0, 0] ) do |sum, goal|
        [
          sum[0] + ( goal.amount_complete_today > goal.daily_goal_amount ? goal.daily_goal_amount : goal.amount_complete_today ),
          sum[1] + goal.daily_goal_amount] 
      end
      if( goal_array.nil? || goal_array[1] == 0 )
        0
      else
        goal_array[0] / goal_array[1]
      end
    end
end

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
  has_many :master_goals
  has_many :daily_goals
  has_many :workweeks, :foreign_key => :worker_id

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :time_zone

  validates :username, :uniqueness => true, :presence => true
  validates :time_zone, :presence => true

  def is_worker?
    user_roles.where( :worker => true ).count > 0
  end

  def current_workweek( time = Time.zone.now )
    workweeks.order( "created_at desc" ).where( "created_at <= ?", time ).first
  end
end

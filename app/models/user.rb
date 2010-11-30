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
  has_many :ticket_times, :as => :worker
  has_many :created_tickets, :class_name => 'Ticket', :as => :created_by_user

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :time_zone

  validates :username, :uniqueness => true, :presence => true
  validates :time_zone, :presence => true
end

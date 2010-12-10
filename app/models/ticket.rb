class Ticket < ActiveRecord::Base
  has_one :billing_rate, :dependent => :destroy
  has_many :comments, :as => :commentable
  has_many :ticket_times
  has_many :user_roles, :as => :manageable
  belongs_to :project
  belongs_to :created_by_user, :class_name => 'User'

  validates :name, :presence => true, :uniqueness => { :scope => :project_id }
  validates :estimated_minutes, :numericality => true, :allow_blank => true
end

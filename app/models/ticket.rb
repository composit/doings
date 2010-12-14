class Ticket < ActiveRecord::Base
  has_one :billing_rate, :as => :billable, :dependent => :destroy
  has_many :comments, :as => :commentable
  has_many :ticket_times
  has_many :user_roles, :as => :manageable
  has_many :user_activity_alerts, :as => :alertable
  belongs_to :project
  belongs_to :created_by_user, :class_name => 'User'

  validates :name, :presence => true, :uniqueness => { :scope => :project_id }
  validates :estimated_minutes, :numericality => true, :allow_blank => true
  validates :created_by_user_id, :presence => true
  validates :billing_rate, :presence => true

  accepts_nested_attributes_for :user_roles

  after_save :generate_alerts

  private
    def generate_alerts
      user_roles.each do |role|
        user_activity_alerts.create!( :user => role.user, :alertable => self, :content => "#{created_by_user.username} created a new ticket called #{name}" ) unless( role.user_id == created_by_user_id )
      end
    end
end

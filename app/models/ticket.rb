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
  validates :project, :presence => true

  accepts_nested_attributes_for :user_roles, :billing_rate

  before_validation :populate_billing_rate
  after_save :generate_alerts, :populate_user_priorities

  def full_name
    "#{project.client.name} - #{project.name} - #{name}"
  end

  def priority_for_user( user )
    user_roles.where( :user_id => user.id ).first.priority
  end

  def self.reprioritize!( user, priority_array )
    priority_array.each do |ticket_id, priority_hash|
      order = priority_hash["new"].to_f
      order = order - 0.5 if( priority_hash["old"] > priority_hash["new"] )
      order = order + 0.5 if( priority_hash["old"] < priority_hash["new"] )
      priority_hash["order"] = order
    end
    priority_array.to_a.sort { |x,y| x[1]["order"] <=> y[1]["order"] }.each_with_index do |ticket_array, index|
      user_role = UserRole.where( :user_id => user.id, :manageable_type => "Ticket", :manageable_id => ticket_array[0] ).first
      user_role.priority = index + 1
      user_role.save( :validate => false )
    end
  end

  private
    def generate_alerts
      user_roles.each do |role|
        user_activity_alerts.create!( :user => role.user, :alertable => self, :content => "#{created_by_user.username} created a new ticket called #{name}" ) unless( role.user_id == created_by_user_id )
      end
    end

    def populate_billing_rate
      self.billing_rate = BillingRate.new( :dollars => project.billing_rate.dollars, :units => project.billing_rate.units ) if( billing_rate.nil? && project )
    end

    def populate_user_priorities
      user_roles.each do |role|
        unless( role.priority )
          role.priority = UserRole.where( :user_id => role.user_id, :manageable_type => "Ticket" ).order( :priority ).last.priority.to_i + 1
          role.save( :validate => false )
        end
      end
    end
end

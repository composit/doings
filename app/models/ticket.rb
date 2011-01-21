class Ticket < ActiveRecord::Base
  belongs_to :billing_rate, :dependent => :destroy
  has_many :billable_billing_rates, :class_name => 'BillingRate', :as => :billable, :dependent => :destroy
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

  attr_accessor :updated_by_user_id, :close_ticket

  accepts_nested_attributes_for :user_roles, :billing_rate

  before_validation :populate_billing_rate, :check_project_closed_status
  after_save :populate_user_priorities, :set_billing_rate_billable
  after_create :generate_creation_alerts
  after_update :generate_update_alerts

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

  def billable_options
    [[( new_record? ? "this ticket" : name ), "Ticket:#{id}"],[project.name,"Project:#{project.id}"],[project.client.name,"Client:#{project.client.id}"]]
  end

  def close_ticket=( closer )
    self.closed_at = Time.zone.now if( closer == "1" )
  end

  private
    def generate_creation_alerts
      generate_alerts( "created" )
    end

    def generate_update_alerts
      generate_alerts( "updated" )
    end

    def generate_alerts( term )
      if( @updated_by_user_id ) # this is not set in rake tasks, etc.
        user_roles.each do |role|
          user_activity_alerts.create!( :user => role.user, :alertable => self, :content => "#{User.find( @updated_by_user_id ).username} #{term} a ticket called #{name}" ) unless( role.user_id == @updated_by_user_id.to_i )
        end
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

    def set_billing_rate_billable
      billing_rate.update_attributes!( :billable => self ) unless( billing_rate.billable )
    end

    def check_project_closed_status
      self.closed_at = Time.zone.now if( project && project.closed_at )
    end
end

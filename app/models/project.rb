class Project < ActiveRecord::Base
  belongs_to :client
  belongs_to :created_by_user, :class_name => 'User'
  belongs_to :billing_rate, :dependent => :destroy
  has_many :billable_billing_rates, :class_name => 'BillingRate', :as => :billable, :dependent => :destroy
  has_many :tickets
  has_many :user_roles, :as => :manageable
  has_many :user_activity_alerts, :as => :alertable

  validates :name, :presence => true, :uniqueness => { :scope => :client_id }
  validates :created_by_user_id, :presence => true
  validates :billing_rate, :presence => true
  validates :client, :presence => true

  attr_accessor :updated_by_user_id, :close_project

  accepts_nested_attributes_for :user_roles, :billing_rate

  before_validation :populate_billing_rate
  before_save :close_tickets_if_applicable
  after_create :generate_creation_alerts
  after_update :generate_update_alerts
  after_save :set_billing_rate_billable

  def build_inherited_ticket( user_id )
    ticket = tickets.new( :created_by_user_id => user_id )
    user_roles.each do |role|
      ticket.user_roles << UserRole.new( role.attributes.reject { |key, value| ["id", "created_at", "updated_at", "manageable_id", "manageable_type"].include?( key ) } )
    end
    ticket.billing_rate = BillingRate.new( :dollars => billing_rate.dollars, :units => billing_rate.units, :billable => billing_rate.billable )
    ticket
  end

  def ticket_times
    TicketTime.joins( :ticket ).where( :tickets => { :project_id => id } )
  end

  def billable_options
    [[( new_record? ? "this project" : name ),"Project:#{id}"],[client.name,"Client:#{client.id}"]]
  end

  def close_project=( closer )
    self.closed_at = Time.zone.now if( closer == "1" )
  end

  def estimated_minutes
    tickets.inject( 0.0 ) { |sum, ticket| sum + ticket.estimated_minutes }
  end

  def minutes_worked
    TicketTime.batch_seconds_worked( ticket_times ) / 60
  end

  private
    def close_tickets_if_applicable
      if( closed_at )
        tickets.each do |ticket|
          ticket.update_attributes!( :closed_at => Time.zone.now ) unless( ticket.closed_at )
        end
      end
    end

    def generate_creation_alerts
      generate_alerts( "created" )
    end

    def generate_update_alerts
      generate_alerts( "updated" )
    end

    def generate_alerts( term )
      if( @updated_by_user_id ) # this is not set in rake tasks, etc.
        user_roles.each do |role|
          user_activity_alerts.create!( :user => role.user, :alertable => self, :content => "#{User.find( @updated_by_user_id ).username} #{term} a project called #{name}" ) unless( role.user_id == @updated_by_user_id.to_i )
        end
      end
    end

    def populate_billing_rate
      self.billing_rate = BillingRate.new( :dollars => client.billing_rate.dollars, :units => client.billing_rate.units ) if( billing_rate.nil? && client )
    end

    def set_billing_rate_billable
      billing_rate.update_attributes!( :billable => self ) unless( billing_rate.billable )
    end
end

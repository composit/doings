class Project < ActiveRecord::Base
  belongs_to :client
  belongs_to :created_by_user, :class_name => 'User'
  has_one :billing_rate, :as => :billable, :dependent => :destroy
  has_many :tickets
  has_many :user_roles, :as => :manageable
  has_many :user_activity_alerts, :as => :alertable

  validates :name, :presence => true, :uniqueness => { :scope => :client_id }
  validates :created_by_user_id, :presence => true
  validates :billing_rate, :presence => true
  validates :client, :presence => true

  accepts_nested_attributes_for :user_roles, :billing_rate

  before_validation :populate_billing_rate
  after_save :generate_alerts

  def build_inherited_ticket( created_by_user_id )
    ticket = tickets.new( :created_by_user_id => created_by_user_id )
    user_roles.each do |role|
      ticket.user_roles << UserRole.new( role.attributes.reject { |key, value| ["id", "created_at", "updated_at", "manageable_id", "manageable_type"].include?( key ) } )
    end
    ticket.billing_rate = BillingRate.new( :dollars => billing_rate.dollars, :units => billing_rate.units )
    ticket
  end

  def ticket_times
    TicketTime.joins( :ticket ).where( :tickets => { :project_id => id } )
  end

  private
    def generate_alerts
      user_roles.each do |role|
        user_activity_alerts.create!( :user => role.user, :alertable => self, :content => "#{created_by_user.username} created a new project called #{name}" ) unless( role.user_id == created_by_user_id )
      end
    end

    def populate_billing_rate
      self.billing_rate = BillingRate.new( :dollars => client.billing_rate.dollars, :units => client.billing_rate.units ) if( billing_rate.nil? && client )
    end
end

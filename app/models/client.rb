class Client < ActiveRecord::Base
  belongs_to :address, :dependent => :destroy
  belongs_to :created_by_user, :class_name => "User"
  belongs_to :billing_rate, :dependent => :destroy
  has_many :billable_billing_rates, :class_name => 'BillingRate', :as => :billable, :dependent => :destroy
  has_many :invoices
  has_many :projects
  has_many :user_roles, :as => :manageable

  validates :name, :presence => true, :uniqueness => true
  validates :web_address, :format => { :with => URI::regexp( %w( http https ) ) }, :allow_blank => true
  validates :billing_rate, :presence => true
  validates :address, :presence => true
  validates :created_by_user_id, :presence => true

  accepts_nested_attributes_for :address, :billing_rate, :user_roles

  after_save :set_billing_rate_billable

  def build_inherited_project( created_by_user_id )
    project = projects.new( :created_by_user_id => created_by_user_id )
    user_roles.each do |role|
      project.user_roles << UserRole.new( role.attributes.reject { |key, value| ["id", "created_at", "updated_at", "manageable_id", "manageable_type"].include?( key ) } )
    end
    project.billing_rate = BillingRate.new( :dollars => billing_rate.dollars, :units => billing_rate.units, :billable => billing_rate.billable )
    project
  end

  def tickets
    Ticket.joins( :project ).where( :projects => { :client_id => id } )
  end
  
  def ticket_times
    TicketTime.joins( :ticket => :project ).where( :projects => { :client_id => id } )
  end

  def billable_options
    [[( new_record? ? "this client" : name ),"Client:#{id}"]]
  end

  private
    def set_billing_rate_billable
      billing_rate.update_attributes!( :billable => self ) unless( billing_rate.billable )
    end
end

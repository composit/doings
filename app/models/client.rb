class Client < ActiveRecord::Base
  belongs_to :address, :dependent => :destroy
  has_one :billing_rate, :as => :billable, :dependent => :destroy
  has_many :invoices
  has_many :office_hours, :as => :workable
  has_many :projects
  has_many :user_roles, :as => :manageable

  validates :name, :presence => true, :uniqueness => true
  validates :web_address, :format => { :with => URI::regexp( %w( http https ) ) }, :allow_blank => true

  accepts_nested_attributes_for :address

  def build_project_with_inherited_roles( created_by_user_id )
    project = projects.new( :created_by_user_id => created_by_user_id )
    user_roles.each do |role|
      project.user_roles << UserRole.new( role.attributes.reject { |key, value| ["id", "created_at", "updated_at", "manageable_id", "manageable_type"].include?( key ) } )
    end
    project
  end
  
  def ticket_times
    TicketTime.joins( :ticket => :project ).where( :projects => { :client_id => id } )
  end
end

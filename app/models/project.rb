class Project < ActiveRecord::Base
  belongs_to :client
  belongs_to :created_by_user, :class_name => 'User'
  has_one :billing_rate, :dependent => :destroy
  has_many :tickets
  has_many :user_roles, :as => :manageable
  has_many :user_activity_alerts, :as => :alertable

  validates :name, :presence => true, :uniqueness => { :scope => :client_id }

  accepts_nested_attributes_for :user_roles

  after_save :generate_alerts

  def build_ticket_with_inherited_roles( created_by_user_id )
    ticket = tickets.new( :created_by_user_id => created_by_user_id )
    user_roles.each do |role|
      ticket.user_roles << UserRole.new( role.attributes.reject { |key, value| ["id", "created_at", "updated_at", "manageable_id", "manageable_type"].include?( key ) } )
    end
    ticket
  end

  private
    def generate_alerts
      user_roles.each do |role|
        user_activity_alerts.create!( :user => role.user, :alertable => self, :content => "#{created_by_user.username} created a new project called #{name}" ) unless( role.user_id == created_by_user_id )
      end
    end
end

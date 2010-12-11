class Project < ActiveRecord::Base
  belongs_to :client
  belongs_to :created_by_user, :class_name => 'User'
  has_one :billing_rate, :dependent => :destroy
  has_many :tickets
  has_many :user_roles, :as => :manageable

  validates :name, :presence => true, :uniqueness => { :scope => :client_id }

  def build_ticket_with_inherited_roles( created_by_user_id )
    ticket = tickets.new( :created_by_user_id => created_by_user_id )
    user_roles.each do |role|
      ticket.user_roles << UserRole.new( role.attributes.reject { |key, value| ["id", "created_at", "updated_at", "manageable_id", "manageable_type"].include?( key ) } )
    end
    ticket
  end
end

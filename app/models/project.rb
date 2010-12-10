class Project < ActiveRecord::Base
  belongs_to :client
  belongs_to :created_by_user, :class_name => 'User'
  has_one :billing_rate, :dependent => :destroy
  has_many :tickets
  has_many :user_roles, :as => :manageable

  validates :name, :presence => true, :uniqueness => { :scope => :client_id }
end
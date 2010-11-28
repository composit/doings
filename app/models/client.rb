class Client < ActiveRecord::Base
  belongs_to :address, :dependent => :destroy
  has_one :billing_rate, :as => :billable, :dependent => :destroy
  has_many :invoices
  has_many :office_hours, :as => :workable

  validates :name, :presence => true, :uniqueness => true
end

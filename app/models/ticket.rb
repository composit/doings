class Ticket < ActiveRecord::Base
  has_one :billing_rate
  has_many :comments, :as => :commentable
  has_many :ticket_times
end

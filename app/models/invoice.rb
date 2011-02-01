class Invoice < ActiveRecord::Base
  belongs_to :client
  belongs_to :created_by_user, :class_name => 'User'
  has_many :ticket_times

  before_destroy :unattach_times

  attr_accessor :invoice_date_string

  def invoice_date_string
    ( invoice_date || Time.zone.now ).strftime( "%Y-%m-%d" )
  end

  def invoice_date_string=( date_string )
    self.invoice_date = Date.parse( date_string )
  end

  private
    def unattach_times
      ticket_times.clear
    end
end

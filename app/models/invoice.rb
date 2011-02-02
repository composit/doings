class Invoice < ActiveRecord::Base
  belongs_to :client
  belongs_to :created_by_user, :class_name => 'User'
  has_many :ticket_times, :autosave => true

  before_destroy :unattach_times

  validates :client, :presence => true

  attr_accessor :invoice_date_string, :include_ticket_times

  def invoice_date_string
    ( invoice_date || Time.zone.now ).strftime( "%Y-%m-%d" )
  end

  def invoice_date_string=( date_string )
    self.invoice_date = Date.parse( date_string )
  end

  def available_ticket_times
    TicketTime.includes( { :ticket => :project } ).where( "ended_at is not null" ).where( "invoice_id = ? or ( invoice_id is null and projects.client_id = ? )", id, client_id ).order( :started_at )
  end

  def include_ticket_times=( times )
    times.each do |ticket_time_id, include|
      #TicketTime.find( ticket_time_id ).update_attributes!( :invoice_id => ( include == "1" ? id : nil ) )
      ticket_time = TicketTime.find( ticket_time_id )
      if( include == "1" )
        ticket_times << TicketTime.find( ticket_time_id ) if( include == "1" )
      elsif( ticket_times.include?( ticket_time ) )
        ticket_times.delete( ticket_time )
      end
    end
  end

  def projects
    ticket_times.collect { |ticket_time| ticket_time.ticket.project }.uniq
  end

  private
    def unattach_times
      ticket_times.clear
    end
end

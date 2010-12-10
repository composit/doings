class TicketTime < ActiveRecord::Base
  belongs_to :worker, :class_name => 'User'
  belongs_to :ticket
  belongs_to :invoice

  validates :started_at, :presence => true
  validates :ended_at, :chronological_times => true

  before_validation :set_start_time, :on => :create

  attr_accessor :stop_now

  def stop_now=( stop )
    self.ended_at = Time.zone.now if( stop == "1" )
  end

  private
    def set_start_time
      self.started_at ||= Time.zone.now
    end
end

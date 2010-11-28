class OfficeHour < ActiveRecord::Base
  belongs_to :workable, :polymorphic => true
  belongs_to :worker, :class_name => 'User'

  validates :day_of_week, :inclusion => { :in => (0..6) }
  validates :start_time, :presence => true
  validates :end_time, :presence => true
end

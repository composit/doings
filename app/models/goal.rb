class Goal < ActiveRecord::Base
  belongs_to :user
  belongs_to :workable, :polymorphic => true

  WORKABLE_TYPES = ["Client", "Project", "Ticket"]
  PERIODS = ["Yearly", "Monthly", "Weekly", "Daily"]

  validates :name, :presence => true
  validates :amount, :presence => true, :numericality => true
  validates :workable_type, :inclusion => { :in => WORKABLE_TYPES }, :allow_blank => true
  validates :period, :presence => true, :inclusion => { :in => PERIODS }
end

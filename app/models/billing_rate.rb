class BillingRate < ActiveRecord::Base
  belongs_to :billable, :polymorphic => true

  UNIT_OPTIONS = ["hour","month"]

  validates :dollars, :numericality => true
  validates :units, :inclusion => { :in => UNIT_OPTIONS, :message => "are not included in the list" }
end

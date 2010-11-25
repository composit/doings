class BillingRate < ActiveRecord::Base
  UNIT_OPTIONS = ["hour","month"]
  validates :dollars, :numericality => true
  validates :units, :inclusion => { :in => UNIT_OPTIONS, :message => "are not included in the list" }
end

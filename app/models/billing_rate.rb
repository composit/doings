class BillingRate < ActiveRecord::Base
  belongs_to :billable, :polymorphic => true

  UNIT_OPTIONS = ["hour","month"]

  validates :dollars, :numericality => true
  validates :units, :inclusion => { :in => UNIT_OPTIONS, :message => "are not included in the list" }

  def description
    "$#{formatted_dollars}/#{units}"
  end

  private
    def formatted_dollars
      if( dollars % 1 == 0 )
        return( dollars.to_i )
      else
        return( sprintf( "%.2f", dollars ) )
      end
    end
end

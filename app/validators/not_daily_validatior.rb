class NotDailyValidator < ActiveModel::EachValidator
  def validate_each( object, attribute, value )
    object.errors[attribute] << "cannot be set for a daily goal" if( !value.nil? && object.period == "Daily" )
  end
end

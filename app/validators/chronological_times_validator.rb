class ChronologicalTimesValidator < ActiveModel::EachValidator
  def validate_each( object, attribute, value )
    object.errors[attribute] << "must be later than started at" if( !value.nil? && value < object.started_at )
  end
end

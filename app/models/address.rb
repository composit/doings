class Address < ActiveRecord::Base
  has_one :client

  STATE_OPTIONS = [ "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY" ]
  PROVINCE_OPTIONS = [ "AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT" ]
  GROUPED_OPTIONS = { "USA" => STATE_OPTIONS, "Canada" => PROVINCE_OPTIONS }
  COUNTRY_OPTIONS = [ "USA", "Canada" ]

  validates :zip_code, :format => /(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1} \d{1}[A-Z]{1}\d{1}$)/, :allow_blank => true
  validates :state, :inclusion => { :in => STATE_OPTIONS + PROVINCE_OPTIONS }, :allow_blank => true
  validates :country, :inclusion => { :in => COUNTRY_OPTIONS }, :allow_blank => true

  def street_address
    [line_1, line_2, city, "#{state}  #{zip_code}", country].reject { |attr| attr.blank? }.compact.join( ", " )
  end
end

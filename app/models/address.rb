class Address < ActiveRecord::Base
  STATE_OPTIONS = [ "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY" ]
  PROVINCE_OPTIONS = [ "AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT" ]
  COUNTRY_OPTIONS = [ "USA", "Canada" ]

  validates_format_of :zip, :with => /(\d{5}(-\d{4})?)|([ABCEGHJKLMNPRSTVXY]\d[A-Z] \d[A-Z]\d)/
  validates_inclusion_of :state, :in => STATE_OPTIONS + PROVINCE_OPTIONS
  validates_inclusion_of :country, :in => COUNTRY_OPTIONS
end

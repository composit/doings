namespace :billing_rates do
  task :update_ids => :environment do
    BillingRate.all.each do |billing_rate|
      billable = billing_rate.billable
      billable.billing_rate_id = billing_rate.id
      billable.save( :validate => false )
    end
  end
end

Given /^the following invoices:$/ do |table|
  table.hashes.each do |hash|
    hash["client"] = Client.find_by_name( hash.delete( "client_name" ) ) if( hash["client_name"] )
    Factory( :invoice, hash )
  end
end

When /^I follow "([^"]*)" for the "([^"]*)" invoice$/ do |link, invoice_date|
  invoice = Invoice.find_by_invoice_date( invoice_date )
  scope = "#invoice-#{invoice.id}"
  with_scope( scope ) do
    click_link( link )
  end
end

When /^I check the ticket time by "([^"]*)"$/ do |worker_username|
  false.should eql( true )
end

When /^I uncheck the ticket time by "([^"]*)"$/ do |worker_username|
  false.should eql( true )
end

Then /^I should see a ticket time by "([^"]*)"$/ do |worker_username|
  with_scope( ".ticket-time" ) do
    page.should have_content( worker_username )
  end
end

Then /^the ticket time by "([^"]*)" should be checked$/ do |worker_username|
  false.should eql( true )
end

Then /^the ticket time by "([^"]*)" should not be checked$/ do |worker_username|
  false.should eql( true )
end

Given /^the following invoices:$/ do |table|
  table.hashes.each do |hash|
    hash["client"] = Client.find_by_name( hash.delete( "client_name" ) ) if( hash["client_name"] )
    Factory( :invoice, hash )
  end
end

When /^I follow "([^"]*)" for the "([^"]*)" invoice$/ do |link, invoice_date|
  invoice = Invoice.find_by_invoice_date( invoice_date )
  with_scope( "\"#invoice-#{invoice.id}\"" ) do
    click_link( link )
  end
end

When /^I check the ticket time by "([^"]*)"$/ do |worker_username|
  page.find( :xpath, "//div[contains(text(), '#{worker_username}')]" ).find( :xpath, "//input[@type='checkbox']" ).check
  #with_scope( page.find( ".content", :text => worker_username ).parent( "div" ) ) do
  #  check( "input" )
  #end
end

When /^I uncheck the ticket time by "([^"]*)"$/ do |worker_username|
  false.should eql( true )
end

Then /^I should see a ticket time by "([^"]*)"$/ do |worker_username|
  with_scope( "\".ticket-time\"" ) do
    page.should have_content( worker_username )
  end
end

Then /^the ticket time by "([^"]*)" should be checked$/ do |worker_username|
  page.find( :xpath, "//div[contains(text(), '#{worker_username}')]/..input[@type='checkbox']" ).should be_checked
end

Then /^the ticket time by "([^"]*)" should not be checked$/ do |worker_username|
  page.find( :xpath, "//div[contains(text(), '#{worker_username}')]/input[@type='checkbox']" ).should_not be_checked
end

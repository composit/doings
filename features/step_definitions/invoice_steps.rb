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

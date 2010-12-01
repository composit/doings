Given /^the following (.+) records:$/ do |factory, table|
  table.hashes.each do |hash|
    Factory( factory, hash )
  end
end

Then /^I should not see a field labeled "([^"]*)"$/ do |label|
  page.should have_no_xpath( "//label", :text => label )
end

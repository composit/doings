Given /^the following (.+) records:$/ do |factory, table|
  table.hashes.each do |hash|
    Factory( factory, hash )
  end
end

Then /^I should not see a field labeled "([^"]*)"$/ do |label|
  page.should have_no_xpath( "//label", :text => label )
end

Then /^"([^"]*)" should not be visible$/ do |text|
  page.should have_xpath( "//*[text()='#{text}']", :visible => false )
end

Then /^"([^"]*)" should be visible$/ do |text|
  page.should have_xpath( "//*[text()='#{text}']", :visible => true )
end

Feature: manage invoices

  Scenario: I should see a link to invoices on the client show page
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | finances |
      | tester        | Test client | true     |
    When I log in as "tester"
    And I follow "Test client"
    Then I should see "invoices"

  Scenario: I should see a link to invoices on the client edit page
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | finances | admin |
      | tester        | Test client | true     | true  |
    When I log in as "tester"
    And I follow "Test client"
    Then I should see "invoices"

  Scenario: I should not see a link to invoices on the client show page if I don't have "finances" access
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | finances |
      | tester        | Test client | false    |
    When I log in as "tester"
    And I follow "Test client"
    Then I should not see "invoices"

  Scenario: I should not see a link to invoices on the client edit page if I don't have "finances" access
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | finances | admin |
      | tester        | Test client | false    | true  |
    When I log in as "tester"
    And I follow "Test client"
    Then I should not see "invoices"

  Scenario: I should be able to view invoices
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | finances | admin |
      | tester        | Test client | true     | true  |
    And the following invoices:
      | client_name | description  | invoice_date |
      | Test client | Test invoice | 2010-01-01   |
    When I log in as "tester"
    And I follow "Test client"
    And I follow "invoices"
    And I follow "2010-01-01"
    Then I should see "Test invoice"

  Scenario: I should be able to create a new invoice
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | finances | admin |
      | tester        | Test client | true     | true  |
    When I log in as "tester"
    And I follow "Test client"
    And I follow "invoices"
    And I follow "New invoice"
    And I fill in "Invoice date" with "2010-01-01"
    And I fill in "Description" with "Test invoice"
    And I press "Create invoice"
    And I follow "Test client"
    And I follow "invoices"
    And I follow "2010-01-01"
    Then I should see "Test invoice"

  Scenario: I should not be able to create a new invoice if I don't have rights to manage finances
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | finances | admin |
      | tester        | Test client | true     | false |
    When I log in as "tester"
    And I follow "Test client"
    And I follow "invoices"
    Then I should not see "New invoice"

    @current
  Scenario: I should be able to edit invoices if I have rights to manage finances
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | finances | admin |
      | tester        | Test client | true     | true  |
    And the following invoices:
      | client_name | invoice_date |
      | Test client | 2010-01-01   |
    When I log in as "tester"
    And I follow "Test client"
    And I follow "invoices"
    And I follow "edit" for the "2010-01-01" invoice
    Then I should see a field labeled "Description"

  Scenario: I should not be able to edit invoices if I don't have rights to manage finances
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | finances | admin |
      | tester        | Test client | true     | false |
    And the following invoices:
      | client_name | invoice_date |
      | Test client | 2010-01-01   |
    When I log in as "tester"
    And I follow "Test client"
    And I follow "invoices"
    Then I should not see "edit"

  Scenario: I should see ticket times associated with the invoice with checked checkboxes
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | finances | admin |
      | tester        | Test client | true     | true  |
    And the following invoices:
      | client_name | invoice_date | description  |
      | Test client | 2010-01-01   | Test invoice |
    And the following ticket times:
      | worker_username | invoice_description | started_at          | ended_at            |
      | tester          | Test invoice        | 2001-01-01 01:01:01 | 2001-01-01 02:02:02 |
    When I log in as "tester"
    And I follow "Test client"
    And I follow "invoices"
    And I follow "edit" for the "2010-01-01" invoice
    Then I should see a ticket time by "tester"
    And the ticket time by "tester" should be checked

  Scenario: I should see ticket times not associated with any invoices
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | finances | admin |
      | tester        | Test client | true     | true  |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following tickets:
      | name        | project_name |
      | Test ticket | Test project |
    And the following invoices:
      | client_name | invoice_date | description  |
      | Test client | 2010-01-01   | Test invoice |
    And the following ticket times:
      | worker_username | ticket_name | started_at          | ended_at            |
      | tester          | Test ticket | 2001-01-01 01:01:01 | 2001-01-01 02:02:02 |
    When I log in as "tester"
    And I follow "Test client"
    And I follow "invoices"
    And I follow "edit" for the "2010-01-01" invoice
    Then I should see a ticket time by "tester"
    And the ticket time by "tester" should not be checked

  Scenario: I should not see ticket times for other clients
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | finances | admin |
      | tester        | Test client | true     | true  |
    And the following invoices:
      | client_name | invoice_date | description  |
      | Test client | 2010-01-01   | Test invoice |
    And the following ticket times:
      | worker_username | started_at          | ended_at            |
      | tester          | 2001-01-01 01:01:01 | 2001-01-01 02:02:02 |
    When I log in as "tester"
    And I follow "Test client"
    And I follow "invoices"
    And I follow "edit" for the "2010-01-01" invoice
    Then I should not see "tester"

  Scenario: I should be able to choose which ticket times belong to an invoice
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | finances | admin |
      | tester        | Test client | true     | true  |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following tickets:
      | name        | project_name |
      | Test ticket | Test project |
    And the following invoices:
      | client_name | invoice_date | description  |
      | Test client | 2010-01-01   | Test invoice |
    And the following ticket times:
      | worker_username | ticket_name | started_at          | ended_at            |
      | tester          | Test ticket | 2001-01-01 01:01:01 | 2001-01-01 02:02:02 |
    And the following ticket times:
      | worker_username | invoice_description | started_at          | ended_at            |
      | other           | Test invoice        | 2001-01-01 01:01:01 | 2001-01-01 02:02:02 |
    When I log in as "tester"
    And I follow "Test client"
    And I follow "invoices"
    And I follow "edit" for the "2010-01-01" invoice
    And I check the ticket time by "tester"
    And I uncheck the ticket time by "other"
    And I press "Update invoice"
    And I follow "Test client"
    And I follow "invoices"
    And I follow "edit" for the "2010-01-01" invoice
    Then I should see a ticket time by "tester"
    And I should see a ticket time by "other"
    And the ticket time by "tester" should be checked
    And the ticket time by "other" should not be checked

  Scenario: I should be able to add a description to an invoice
    pending

  Scenario: I should see who created an invoice
    pending

  Scenario: I should be able to select an invoice date
    pending

  Scenario: I should be able to add a paid date
    pending

  Scenario: I should see a link to invoices in the sidebar if work has been completed older than the client's invoice range
    pending

  Scenario: I should not see a link to invoices in the sidebar if work has been completed older than the client's invoice range if I don't have rights to manage finances
    pending

  Scenario: I should see a link to invoices in the sidebar if a client has an overdue invoice
    pending

  Scenario: I should not see a link to invoices in the sidebar if a client has an overdue invoice if I don't have rights to manage finances
    pending

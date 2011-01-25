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

    @current
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

  Scenario: I should not be able to edit invoices if I don't have rights to manage finances
    pending

  Scenario: I should be able to choose which ticket times belong to an invoice
    pending

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

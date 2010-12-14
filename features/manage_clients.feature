Feature: manage clients

  Scenario: I should be able to edit client information if I have admin access to that client
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | admin |
      | tester        | Test client | true  |
    When I log in as "tester"
    And I follow "Test client"
    And I fill in "Name" with "New name"
    And I press "Update"
    Then I should see "Client was successfully updated"
    And the "Name" field should contain "New name"

  Scenario: I should not be able to edit client information if I don't have admin access to that client
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    When I log in as "tester"
    And I follow "Test client"
    Then I should not see a field labeled "Name"

  Scenario: I should be able to create a new address if the client doesn't have an address
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | admin |
      | tester        | Test client | true  |
    When I log in as "tester"
    And I follow "Test client"
    And I fill in "Line 1" with "Test address"
    And I press "Update"
    Then I should see "Client was successfully updated"
    And the "Line 1" field should contain "Test address"

  Scenario: I should be able to update billing rate info for a client
    pending

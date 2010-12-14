Feature: manage clients

  Scenario: I should see clients I am connected with in the details section of the projects page
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
    And the following client records:
      | name         |
      | Test client  |
      | Other client |
    And the following user roles:
      | user_username | client_name  |
      | tester        | Test client  |
      | other         | Other client |
    When I log in as "tester"
    And I am on the projects page
    Then I should see "Test client"
    And I should not see "Other client"

  Scenario: I should get to the edit client page by clicking the client name, even without admin rights
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
    And I am on the projects page
    And I follow "Test client"
    Then I should be on the client page for "Test client"

  Scenario: I should only see a specific client's projects by clicking their "projects" link
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name         |
      | Test client  |
      | Other client |
    And the following projects:
      | name          | client_name  |
      | Test project  | Test client  |
      | Other project | Other client |
    And the following user roles:
      | user_username | client_name  |
      | tester        | Test client  |
      | tester        | Other client |
    And the following user roles:
      | user_username | project_name  |
      | tester        | Test project  |
      | tester        | Other project |
    When I log in as "tester"
    And I am on the projects page
    When I follow "projects" for the "Test client" client
    Then I should see "Test project"
    And I should not see "Other project"

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
    And I fill in "Billing rate" with "10"
    And I select "hour" from "per"
    And I press "Update"
    Then I should see "Client was successfully updated"
    And the "Billing rate" field should contain "10"
    And the "per" field should contain "hour"

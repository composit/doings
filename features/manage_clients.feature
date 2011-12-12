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
    And I follow "projects"
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
    And I follow "projects"
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
    And I follow "projects"
    When I follow "projects" for the "Test client" client
    Then I should see "Test project"
    And I should not see "Other project"

    @currentz
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

    @current
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

    @current
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

  Scenario: I should be able to create new clients
    When I log in as "tester"
    And I follow "New client"
    And I fill in "Name" with "Test client"
    And I fill in "Billing rate" with "100"
    And I press "Create client"
    And I am on the panel page
    Then I should see "Test client"

  Scenario: I should be alerted if the client fails validation
    When I log in as "tester"
    And I follow "New client"
    And I fill in "Name" with "Test client"
    And I press "Create client"
    Then I should see "Billing rate dollars is not a number"

  Scenario: I should have admin permissions on a client I create
    When I log in as "tester"
    And I follow "New client"
    And I fill in "Name" with "Test client"
    And I fill in "Billing rate" with "100"
    And I press "Create client"
    And I am on the panel page
    And I follow "Test client"
    Then the "Admin" checkbox should be checked

  Scenario: I should be able to give myself worker, etc. permissions on newly created clients
    When I log in as "tester"
    And I follow "New client"
    And I fill in "Name" with "Test client"
    And I fill in "Billing rate" with "100"
    And I check "Worker"
    And I press "Create client"
    And I am on the panel page
    And I follow "Test client"
    Then the "Worker" checkbox should be checked

  Scenario: It should keep track of who created a client
    When I log in as "tester"
    And I follow "New client"
    And I fill in "Name" with "Test client"
    And I fill in "Billing rate" with "100"
    And I press "Create client"
    And I am on the panel page
    And I follow "Test client"
    Then I should see "created by tester"

  Scenario: Clients in sidebar should display in alphabetical order
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name            |
      | C Last client   |
      | A First client  |
      | B Middle client |
    And the following user roles:
      | user_username | client_name   |
      | tester        | B Middle client |
      | tester        | A First client  |
      | tester        | C Last client   |
    When I log in as "tester"
    Then I should see the following text in order:
      | text            |
      | A First client  |
      | B Middle client |
      | C Last client   |

  Scenario: I should see error messages when editing a client and entering bad info
    pending

Feature: manage billing rates

  @javascript
  Scenario: I should not see the estimated hourly rate field if my rate is hourly
    When I log in as "tester"
    And I follow "New client"
    And I select "hour" from "per"
    Then "Hourly rate for calculations" should not be visible

  @javascript
  Scenario: I should see the estimated hourly rate field if my rate is not hourly
    When I log in as "tester"
    And I follow "New client"
    And I select "total" from "per"
    Then "Hourly rate for calculations" should be visible

  @javascript
  Scenario: If the hourly rate for calculations field is hidden, it should not submit data
    When I log in as "tester"
    And I follow "New client"
    And I fill in "Name" with "Test client"
    And I fill in "Billing rate" with "1000"
    And I select "total" from "per"
    And I fill in "Hourly rate for calculations" with "777"
    And I select "hour" from "per"
    And I press "Create client"
    And I follow "Test client"
    And I select "total" from "per"
    Then the "Hourly rate for calculations" field should contain "1000.0"

  @javascript
  Scenario: I should not see the billable field if my rate is hourly
    When I log in as "tester"
    And I follow "New client"
    And I select "hour" from "per"
    Then "for" should not be visible

  @javascript
  Scenario: I should see the billable field if my rate is not hourly
    When I log in as "tester"
    And I follow "New client"
    And I select "total" from "per"
    Then "for" should be visible

    @current
  @javascript
  Scenario: If the billable field is hidden, it should not submit data
    Given the following confirmed_user records:
      | username |
      | tester   |
    Given the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name | admin | finances |
      | tester        | Test client | true  | true     |
    And the following user roles:
      | user_username | project_name | admin | finances |
      | tester        | Test project | true  | true     |
    And the following billing rates:
      | project_name | units | billable_project_name |
      | Test project | total | Test project          |
    When I log in as "tester"
    And I follow "projects" for the "Test client" client
    And I follow "edit" for the "Test project" project
    And I wait for 1 second
    And I select "Test client" from "for"
    And I select "hour" from "per"
    And I press "Update project"
    And I follow "edit" for the "Test project" project
    And I wait for 1 second
    And I select "total" from "per"
    Then the "for" field should contain "Project:"

  @javascript
  Scenario: The billable should be selected in the dropdown
    Given the following confirmed_user records:
      | username |
      | tester   |
    Given the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name | admin | finances |
      | tester        | Test client | true  | true     |
    And the following user roles:
      | user_username | project_name | admin | finances |
      | tester        | Test project | true  | true     |
    And the following billing rates:
      | project_name | units | billable_client_name |
      | Test project | total | Test client          |
    When I log in as "tester"
    And I follow "projects" for the "Test client" client
    And I follow "edit" for the "Test project" project
    Then the "for" field should contain "Client:"

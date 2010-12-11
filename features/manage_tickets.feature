Feature: manage tickets

  @javascript
  Scenario: I should see a project's tickets that I'm attached to when I click "tickets"
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name         |
      | Other client |
    And the following projects:
      | name          |
      | Test project  |
      | Other project |
    And the following tickets:
      | name           | project_name  |
      | Test ticket    | Test project  |
      | Other ticket 1 | Other project |
      | Other ticket 2 | Test project  |
    And the following user roles:
      | user_username | client_name  |
      | tester        | Other client |
    And the following user roles:
      | user_username | project_name |
      | tester        | Test project |
    And the following user roles:
      | user_username | ticket_name    |
      | tester        | Test ticket    |
      | tester        | Other ticket 1 |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    Then I should see "Test ticket"
    And I should not see "Other ticket"

  Scenario: The "tickets" and "collapse" links should show and hide appropriately
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following projects:
      | name         |
      | Test project |
    And the following tickets:
      | name           | project_name |
      | Test ticket    | Test project |
    And the following user roles:
      | user_username | project_name |
      | tester        | Test project |
    And the following user roles:
      | user_username | ticket_name |
      | tester        | Test ticket |
    When I log in as "tester"
    And I am on the projects page
    Then "tickets" should be visible
    Then "collapse" should not be visible
    When I follow "tickets"
    Then "tickets" should not be visible
    Then "collapse" should be visible
    When I follow "collapse"
    Then "tickets" should be visible
    Then "collapse" should not be visible

  @javascript
  Scenario: I should be able to hide a project's tickets when I click "collapse"
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following projects:
      | name         |
      | Test project |
    And the following tickets:
      | name           | project_name |
      | Test ticket    | Test project |
    And the following user roles:
      | user_username | project_name |
      | tester        | Test project |
    And the following user roles:
      | user_username | ticket_name |
      | tester        | Test ticket |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    Then I should see "Test ticket"
    When I follow "collapse"
    Then I should not see "Test ticket"

  @javascript
  Scenario: I should not be able to add new tickets to projects I don't have admin access to
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following projects:
      | name         |
      | Test project |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | false |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    Then I should not see "new ticket"

  @javascript
  Scenario: I should be able to add new tickets from the projects page
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following projects:
      | name         |
      | Test project |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    And I fill in "Name" with "Test ticket"
    And I press "Create ticket"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    Then I should see "Test ticket"

  @javascript
  Scenario: If I try to create a new ticket, but don't enter a name, I should see an alert
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following projects:
      | name         |
      | Test project |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    And I press "Create ticket"
    Then I should see "t be blank"

  @javascript
  Scenario: I should be able to add multiple tickets in a row without refreshing the page
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following projects:
      | name         |
      | Test project |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    And I fill in "Name" with "Test ticket"
    And I press "Create ticket"
    And I wait for 1 second
    When I follow "new ticket" for the "Test project" project
    And I fill in "Name" with "Test ticket 2"
    And I press "Create ticket"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    Then I should see "Test ticket 2"

  Scenario: Adding new tickets should alert everyone associated with the project
    pending

  Scenario: I should be able to assign rights to the ticket I'm creating
    pending

  Scenario: The rights to the ticket I'm creating should default to the rights for the project that ticket belongs to
    pending

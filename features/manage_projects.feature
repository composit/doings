Feature: manage projects

  Scenario: I should not be able to get to the projects page if I am not logged in
    When I am on the projects page
    Then I should see "You need to sign in or sign up before continuing."
    And I should be on the new user session page

  Scenario: I should only see projects I am connected with
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
    And the following project records:
      | name          |
      | Test project  |
      | Other project |
    And the following user roles:
      | user_username | project_name  |
      | tester        | Test project  |
      | other         | Other project |
    When I log in as "tester"
    And I am on the projects page
    Then I should see "Test project"
    And I should not see "Other project"

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

  Scenario: I should be able to see all projects by clicking the "projects" link associated with "All clients"
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name         |
      | Other client |
    And the following projects:
      | name          |
      | Test project  |
    And the following user roles:
      | user_username | client_name  |
      | tester        | Other client |
    And the following user roles:
      | user_username | project_name |
      | tester        | Test project |
    When I log in as "tester"
    And I am on the projects page
    And I follow "projects" for the "Other client" client
    Then I should not see "Test project"
    When I follow "projects" for the "All clients" client
    Then I should see "Test project"

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

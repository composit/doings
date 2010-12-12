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

  Scenario: I should not be able to add new projects from the general projects page
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name         |
      | Other client |
    And the following user roles:
      | user_username | client_name  |
      | tester        | Other client |
    When I log in as "tester"
    And I am on the projects page
    Then I should not see "new project"

  Scenario: I should not be able to add new projects to clients I don't have admin access to
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name         |
      | Other client |
    And the following user roles:
      | user_username | client_name  |
      | tester        | Other client |
    When I log in as "tester"
    And I am on the projects page
    And I follow "projects" for the "Other client" client
    Then I should not see "new project"

  @javascript @current
  Scenario: I should be able to add new projects from the projects page
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name         |
      | Test client  |
    And the following user roles:
      | user_username | client_name  | admin |
      | tester        | Test client  | true  |
    When I log in as "tester"
    And I am on the projects page
    And I follow "projects" for the "Test client" client
    And I follow "new project"
    And I fill in "Name" with "Test project"
    And I press "Create project"
    And I am on the projects page
    And I follow "projects" for the "Test client" client
    Then I should see "Test project"

  Scenario: If I try to add an invalid project, I should see an alert
    pending

  Scenario: I should be able to add multiple projects without refreshing the page
    pending

  Scenario: Creating projects should alert everyone associated with the client except the creator
    pending

  Scenario: I should be able to assign rights to the project I'm creating
    pending

  Scenario: The rights to the project I'm creating should default to the rights for the client that project belongs to
    pending

  Scenario: When I create a project, it should keep track of and display who it was created by
    pending

  Scenario: I should be able to create a new project and create a new ticket for that project without refreshing the page
    pending

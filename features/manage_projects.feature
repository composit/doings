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

    @current
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

  @javascript
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

  @javascript
  Scenario: If I try to add an invalid project, I should see an alert
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
    And I press "Create project"
    Then I should see "t be blank"

  @javascript
  Scenario: I should be able to add multiple projects without refreshing the page
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
    And I wait for 1 second
    And I follow "new project"
    And I fill in "Name" with "Test project 2"
    And I press "Create project"
    And I am on the projects page
    And I follow "projects" for the "Test client" client
    Then I should see "Test project 2"

  @javascript
  Scenario: I should be able to assign rights to the project I'm creating
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
      | another  |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | admin |
      | tester        | Test client | true  |
      | other         | Test client | true  |
      | another       | Test client | false |
    When I log in as "tester"
    And I am on the projects page
    And I follow "projects" for the "Test client" client
    And I follow "new project"
    And I fill in "Name" with "Test project"
    And I uncheck "Admin" in the roles for "other"
    And I check "Admin" in the roles for "another"
    And I press "Create project"
    And I wait for 1 second
    Then the following roles should be set:
      | user_username | project_name | admin |
      | other         | Test project | 0     |
      | another       | Test project | 1     |

  @javascript
  Scenario: The rights to the project I'm creating should default to the rights for the client that project belongs to
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | admin | worker |
      | tester        | Test client | true  | false  |
      | other         | Test client | false | true   |
    When I log in as "tester"
    And I am on the projects page
    And I follow "projects" for the "Test client" client
    And I follow "new project"
    Then the "Admin" checkbox in the roles for "tester" should be checked
    And the "Worker" checkbox in the roles for "tester" should not be checked
    And the "Admin" checkbox in the roles for "other" should not be checked
    And the "Worker" checkbox in the roles for "other" should be checked

  @javascript
  Scenario: I should not be able to remove admin rights for myself for a project I'm creating
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
    And I am on the projects page
    And I follow "projects" for the "Test client" client
    And I follow "new project"
    Then the "Admin" checkbox in the roles for "tester" should be disabled

  @javascript
  Scenario: When I create a project, it should keep track of and display who it was created by
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
    Then I should see "created by tester"

  @javascript @current
  Scenario: I should be able to create a new project and create a new ticket for that project without refreshing the page
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
    And I wait for 1 second
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket"
    And I fill in "Name" with "Test ticket"
    And I press "Create ticket"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    Then I should see "Test ticket"

  Scenario: I should be able to enter billing rate info when entering a new project
    pending

  Scenario: the billing rate info for a new ticket should default to the billing rate info for its client
    pending

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

  @javascript
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

  @javascript
  Scenario: I should be able to enter billing rate info when entering a new project
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name         |
      | Test client  |
    And the following user roles:
      | user_username | client_name  | admin | finances |
      | tester        | Test client  | true  | true     |
    When I log in as "tester"
    And I am on the projects page
    And I follow "projects" for the "Test client" client
    And I follow "new project"
    And I fill in "Name" with "Test project"
    And I fill in "Billing rate" with "10"
    And I select "hour" from "per"
    And I press "Create project"
    And I am on the projects page
    And I follow "projects" for the "Test client" client
    Then I should see "$10/hour"

  @javascript
  Scenario: the billing rate info for a new ticket should default to the billing rate info for its client
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name         |
      | Test client  |
    And the following billing rates:
      | client_name | dollars | units |
      | Test client | 100     | month |
    And the following user roles:
      | user_username | client_name  | admin | finances |
      | tester        | Test client  | true  | true     |
    When I log in as "tester"
    And I am on the projects page
    And I follow "projects" for the "Test client" client
    And I follow "new project"
    Then the "Billing rate" field should contain "100"
    And the "per" field should contain "month"

  Scenario: I should not see the billing rate if I do not have "finances" access to the project
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following project records:
      | name         |
      | Test project |
    And the following billing rates:
      | project_name | dollars | units |
      | Test project | 100     | hour  |
    And the following user roles:
      | user_username | project_name | finances |
      | tester        | Test project | false    |
    When I log in as "tester"
    And I am on the projects page
    Then I should not see "$100/hour"

  @javascript
  Scenario: I should not be able to update a billing rate for a project if I don't have "finances" and "admin" access to the project
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name         |
      | Test client  |
    And the following user roles:
      | user_username | client_name  | admin | finances |
      | tester        | Test client  | true  | false    |
    When I log in as "tester"
    And I am on the projects page
    And I follow "projects" for the "Test client" client
    And I follow "new project"
    Then I should not see a field labeled "Billing rate"
    And I should not see a field labeled "per"

  @javascript
  Scenario: I should be able to assign financial roles if I have the financial role
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name         |
      | Test client  |
    And the following user roles:
      | user_username | client_name  | admin | finances |
      | tester        | Test client  | true  | true     |
    When I log in as "tester"
    And I am on the projects page
    And I follow "projects" for the "Test client" client
    And I follow "new project"
    Then the "Finances" checkbox in the roles for "tester" should not be disabled

  @javascript
  Scenario: I should not be able to assign financial roles if I don't have the financial role
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
    And the following client records:
      | name         |
      | Test client  |
    And the following user roles:
      | user_username | client_name  | admin | finances |
      | tester        | Test client  | true  | false    |
      | other         | Test client  | true  | false    |
    When I log in as "tester"
    And I am on the projects page
    And I follow "projects" for the "Test client" client
    And I follow "new project"
    Then the "Finances" checkbox in the roles for "tester" should be disabled
    And the "Finances" checkbox in the roles for "other" should be disabled

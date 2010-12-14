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
  Scenario: If I try to create an invalid ticket, I should see an alert
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
    And I follow "new ticket" for the "Test project" project
    And I fill in "Name" with "Test ticket 2"
    And I press "Create ticket"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    Then I should see "Test ticket 2"

  @javascript @current
  Scenario: I should be able to assign rights to the ticket I'm creating
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
      | another  |
    And the following projects:
      | name         |
      | Test project |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
      | other         | Test project | true  |
      | another       | Test project | false |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    And I fill in "Name" with "Test ticket"
    And I uncheck "Admin" in the roles for "other"
    And I check "Admin" in the roles for "another"
    And I press "Create ticket"
    And I wait for 1 second
    Then the following roles should be set:
      | user_username | ticket_name | admin |
      | other         | Test ticket | 0     |
      | another       | Test ticket | 1     |

  @javascript
  Scenario: The rights to the ticket I'm creating should default to the rights for the project that ticket belongs to
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
    And the following projects:
      | name         |
      | Test project |
    And the following user roles:
      | user_username | project_name | admin | worker |
      | tester        | Test project | true  | false  |
      | other         | Test project | false | true   |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    Then the "Admin" checkbox in the roles for "tester" should be checked
    And the "Worker" checkbox in the roles for "tester" should not be checked
    And the "Admin" checkbox in the roles for "other" should not be checked
    And the "Worker" checkbox in the roles for "other" should be checked

  @javascript
  Scenario: I should not be able to remove admin rights for myself for a ticket I'm creating
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
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
    Then the "Admin" checkbox in the roles for "tester" should be disabled

  @javascript
  Scenario: When I create a ticket, it should keep track of and display who it was created by
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
    Then I should see "created by tester"

  @javascript
  Scenario: I should be able to enter billing rate info when entering a new ticket
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
    And I fill in "Billing rate" with "10"
    And I select "hour" from "per"
    And I press "Create ticket"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    Then I should see "$10/hour" within ".ticket"

  @javascript
  Scenario: the billing rate info for a new ticket should default to the billing rate info for its project
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following projects:
      | name         |
      | Test project |
    And the following billing rates:
      | project_name | dollars | units |
      | Test project | 100     | month |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    Then the "Billing rate" field should contain "100"
    And the "per" field should contain "month"

Feature: manage tickets

  @javascript
  Scenario: I should see a project's tickets that I'm attached to when I click "tickets" on the projects page
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

  Scenario: The "tickets" and "collapse" links should show and hide appropriately on the projects page
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
  Scenario: I should be able to hide a project's tickets when I click "collapse" on the projects page
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

  @javascript
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
      | user_username | project_name | admin | finances |
      | tester        | Test project | true  | true     |
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
      | user_username | project_name | admin | finances |
      | tester        | Test project | true  | true     |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    Then the "Billing rate" field should contain "100"
    And the "per" field should contain "month"

  @javascript
  Scenario: I should not see the billing rate if I do not have "finances" access to the ticket
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following project records:
      | name         |
      | Test project |
    And the following tickets:
      | name        | project_name |
      | Test ticket | Test project |
    And the following billing rates:
      | ticket_name | dollars | units |
      | Test ticket | 100     | hour  |
    And the following user roles:
      | user_username | project_name |
      | tester        | Test project |
    And the following user roles:
      | user_username | ticket_name | finances |
      | tester        | Test ticket | false    |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    Then I should not see "$100/hour" within ".ticket"

  @javascript
  Scenario: I should not be able to update a billing rate for a ticket if I don't have "finances" and "admin" access to the ticket
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following project records:
      | name         |
      | Test project |
    And the following user roles:
      | user_username | project_name  | admin | finances |
      | tester        | Test project  | true  | false    |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket"
    Then I should not see a field labeled "Billing rate"
    And I should not see a field labeled "per"

  @javascript
  Scenario: I should be able to assign financial roles if I have the financial role
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following project records:
      | name         |
      | Test project |
    And the following user roles:
      | user_username | project_name  | admin | finances |
      | tester        | Test project  | true  | true     |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket"
    Then the "Finances" checkbox in the roles for "tester" should not be disabled

  @javascript
  Scenario: I should not be able to assign financial roles if I don't have the financial role
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
    And the following project records:
      | name         |
      | Test project |
    And the following user roles:
      | user_username | project_name | admin | finances |
      | tester        | Test project | true  | false    |
      | other         | Test project | true  | false    |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket"
    Then the "Finances" checkbox in the roles for "tester" should be disabled
    And the "Finances" checkbox in the roles for "other" should be disabled

  Scenario: I should be able to get to the ticket priority page by clicking "Ticket priorities"
    When I log in as "tester"
    And I follow "Ticket priorities"
    Then I should be on the tickets page

  Scenario: I should not see other users' tickets on the ticket priority page
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following tickets:
      | name        |
      | Good ticket |
      | Bad ticket  |
    And the following user roles:
      | user_username | ticket_name |
      | tester        | Good ticket |
    When I log in as "tester"
    And I am on the tickets page
    Then I should see "Good ticket"
    And I should not see "Bad ticket"

  Scenario: I should be able to prioritize tickets
    Given the following worker records:
      | username |
      | tester   |
    And the following ticket records:
      | name         |
      | Ticket one   |
      | Ticket two   |
    And the following user roles:
      | user_username | ticket_name  | priority |
      | tester        | Ticket one   | 1        |
      | tester        | Ticket two   | 2        |
    When I log in as "tester"
    And I am on the tickets page
    And I fill in "2" for the "Ticket one" ticket priority
    And I fill in "1" for the "Ticket two" ticket priority
    And I press "Reprioritize"
    Then I should see the following text in order:
      | text       |
      | Ticket two |
      | Ticket one |

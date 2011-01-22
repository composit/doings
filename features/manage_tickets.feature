Feature: manage tickets

  @javascript
  Scenario: I should see a project's tickets that I'm attached to when I click "tickets" on the projects page
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name         |
      | Test client  |
      | Other client |
    And the following projects:
      | name          | client_name |
      | Test project  | Test client |
      | Other project | Test client |
    And the following tickets:
      | name           | project_name  |
      | Test ticket    | Test project  |
      | Other ticket 1 | Other project |
      | Other ticket 2 | Test project  |
    And the following user roles:
      | user_username | client_name  |
      | tester        | Test client  |
      | tester        | Other client |
    And the following user roles:
      | user_username | project_name |
      | tester        | Test project |
    And the following user roles:
      | user_username | ticket_name    |
      | tester        | Test ticket    |
      | tester        | Other ticket 1 |
    When I log in as "tester"
    And I follow "projects" for the "Test client" client
    And I follow "tickets" for the "Test project" project
    Then I should see "Test ticket"
    And I should not see "Other ticket"

  Scenario: The "tickets" and "collapse" links should show and hide appropriately on the projects page
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following tickets:
      | name           | project_name |
      | Test ticket    | Test project |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name |
      | tester        | Test project |
    And the following user roles:
      | user_username | ticket_name |
      | tester        | Test ticket |
    When I log in as "tester"
    And I follow "projects"
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
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following tickets:
      | name           | project_name |
      | Test ticket    | Test project |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name |
      | tester        | Test project |
    And the following user roles:
      | user_username | ticket_name |
      | tester        | Test ticket |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    Then I should see "Test ticket"
    When I follow "collapse"
    Then I should not see "Test ticket"

  @javascript
  Scenario: I should not be able to add new tickets to projects I don't have admin access to
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | false |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    Then I should not see "new ticket"

  @javascript
  Scenario: I should be able to add new tickets from the projects page
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    And I fill in "Name" with "Test ticket"
    And I press "Create ticket"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    Then I should see "Test ticket"

  @javascript
  Scenario: I should be able to cancel out of new ticket creation
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    And I fill in "Name" with "Test ticket"
    And I follow "cancel"
    Then "Name" should not be visible
    When I follow "projects"
    And I follow "tickets" for the "Test project" project
    Then I should not see "Test ticket"

  @javascript
  Scenario: If I try to create an invalid ticket, I should see an alert
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    And I press "Create ticket"
    Then I should see "t be blank"

  @javascript
  Scenario: I should be able to add multiple tickets in a row without refreshing the page
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    And I fill in "Name" with "Test ticket"
    And I press "Create ticket"
    And I wait for 1 second
    And I follow "new ticket" for the "Test project" project
    And I fill in "Name" with "Test ticket 2"
    And I press "Create ticket"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    Then I should see "Test ticket 2"

  @javascript
  Scenario: I should be able to assign rights to the ticket I'm creating
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
      | another  |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
      | other         | Test project | true  |
      | another       | Test project | false |
    When I log in as "tester"
    And I follow "projects"
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
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin | worker |
      | tester        | Test project | true  | false  |
      | other         | Test project | false | true   |
    When I log in as "tester"
    And I follow "projects"
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
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    Then the "Admin" checkbox in the roles for "tester" should be disabled

  @javascript
  Scenario: When I create a ticket, it should keep track of and display who it was created by
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    And I fill in "Name" with "Test ticket"
    And I press "Create ticket"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    Then I should see "created by tester"

  @javascript
  Scenario: I should be able to enter billing rate info when entering a new ticket
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin | finances |
      | tester        | Test project | true  | true     |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    And I fill in "Name" with "Test ticket"
    And I fill in "Billing rate" with "10"
    And I select "hour" from "per"
    And I press "Create ticket"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    Then I should see "$10/hour" within ".ticket"

  @javascript
  Scenario: the billing rate info for a new ticket should default to the billing rate info for its project
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following billing rates:
      | project_name | dollars | units |
      | Test project | 100     | month |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin | finances |
      | tester        | Test project | true  | true     |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket" for the "Test project" project
    Then the "Billing rate" field should contain "100"
    And the "per" field should contain "month"

  @javascript
  Scenario: I should not see the billing rate if I do not have "finances" access to the ticket, even if I have it for the project
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following tickets:
      | name        | project_name |
      | Test ticket | Test project |
    And the following billing rates:
      | ticket_name | dollars | units |
      | Test ticket | 100     | hour  |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | finances |
      | tester        | Test project | true     |
    And the following user roles:
      | user_username | ticket_name | finances |
      | tester        | Test ticket | false    |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    Then I should not see "$100/hour" within ".ticket"

  @javascript
  Scenario: I should not be able to update a billing rate for a ticket if I don't have "finances" and "admin" access to the ticket
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name  | admin | finances |
      | tester        | Test project  | true  | false    |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket"
    Then I should not see a field labeled "Billing rate"
    And I should not see a field labeled "per"

  @javascript
  Scenario: I should be able to assign financial roles if I have the financial role
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name  | admin | finances |
      | tester        | Test project  | true  | true     |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "new ticket"
    Then the "Finances" checkbox in the roles for "tester" should not be disabled

  @javascript
  Scenario: I should not be able to assign financial roles if I don't have the financial role
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin | finances |
      | tester        | Test project | true  | false    |
      | other         | Test project | true  | false    |
    When I log in as "tester"
    And I follow "projects"
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

  @javascript
  Scenario: I should be able to edit tickets
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following tickets:
      | name        | project_name |
      | Test ticket | Test project |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    And the following user roles:
      | user_username | ticket_name | admin |
      | tester        | Test ticket | true  |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "edit" for the "Test ticket" ticket
    And I wait for 1 second
    And I fill in "Name" with "New name"
    And I press "Update ticket"
    And I follow "projects" for the "Test client" client
    And I follow "tickets" for the "Test project" project
    Then I should see "New name"

  @javascript
  Scenario: I should be able to cancel out of the edit form without saving my changes
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following tickets:
      | name        | project_name |
      | Test ticket | Test project |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    And the following user roles:
      | user_username | ticket_name | admin |
      | tester        | Test ticket | true  |
    When I log in as "tester"
    And I follow "projects" for the "Test client" client
    And I follow "tickets" for the "Test project" project
    And I follow "edit" for the "Test ticket" ticket
    And I wait for 1 second
    And I fill in "Name" with "New name"
    And I follow "cancel"
    Then "Name" should not be visible
    When I follow "projects" for the "Test client" client
    And I follow "tickets" for the "Test project" project
    Then I should not see "New name"

  @javascript
  Scenario: I should see validation errors if a ticket I am editing fails validation
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following tickets:
      | name        | project_name |
      | Test ticket | Test project |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    And the following user roles:
      | user_username | ticket_name | admin |
      | tester        | Test ticket | true  |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "edit" for the "Test ticket" ticket
    And I wait for 1 second
    And I fill in "Name" with ""
    And I press "Update ticket"
    Then I should see "t be blank"

  @javascript
  Scenario: I should not be able to edit tickets I do not have admin access to
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following tickets:
      | name        | project_name | id |
      | Test ticket | Test project | 1  |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    And the following user roles:
      | user_username | ticket_name | admin |
      | tester        | Test ticket | false |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    Then I should not see "edit" within "#ticket-1"

  @javascript
  Scenario: I should be able to close a ticket
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following tickets:
      | name        | project_name |
      | Test ticket | Test project |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    And the following user roles:
      | user_username | ticket_name | admin |
      | tester        | Test ticket | true  |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "edit" for the "Test ticket" ticket
    And I check "Close ticket"
    And I press "Update ticket"
    And I wait for 1 second
    Then I should not see "Test ticket"

  @javascript
  Scenario: I should not see closed tickets when I expand the tickets for a project
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following tickets:
      | name        | project_name | closed_at           |
      | Test ticket | Test project | 2001-02-03 04:05:06 |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name | admin |
      | tester        | Test project | true  |
    And the following user roles:
      | user_username | ticket_name | admin |
      | tester        | Test ticket | true  |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I wait for 1 second
    Then I should not see "Test ticket"

  @javascript
  Scenario: Tickets should be ordered by priority
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following projects:
      | name         | client_name |
      | Test project | Test client |
    And the following tickets:
      | name          | project_name |
      | Middle ticket | Test project |
      | Top ticket    | Test project |
      | Bottom ticket | Test project |
    And the following user roles:
      | user_username | client_name |
      | tester        | Test client |
    And the following user roles:
      | user_username | project_name |
      | tester        | Test project |
    And the following user roles:
      | user_username | ticket_name   | priority |
      | tester        | Middle ticket | 2        |
      | tester        | Top ticket    | 1        |
      | tester        | Bottom ticket | 3        |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I wait for 1 second
    Then I should see the following text in order:
      | text          |
      | Top ticket    |
      | Middle ticket |
      | Bottom ticket |

  @current
  Scenario: Prioritization page should not show closed tickets
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following tickets:
      | name        |
      | Test ticket |
    And the following tickets:
      | name          | closed_at           |
      | Closed ticket | 2001-01-01 01:01:01 |
    And the following user roles:
      | user_username | ticket_name   |
      | tester        | Test ticket   |
      | tester        | Closed ticket |
    When I log in as "tester"
    And I am on the tickets page
    Then I should see "Test ticket"
    And I should not see "Closed ticket"

Feature: manage ticket times

  @javascript
  Scenario: I should not see the "start" link for a ticket if I am not a worker for that ticket
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
      | user_username | project_name | worker |
      | tester        | Test project | true   |
    And the following user roles:
      | user_username | ticket_name |
      | tester        | Test ticket |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    Then I should see "Test ticket"
    And I should not see "start"

  @javascript
  Scenario: I should be able to create a new ticket time by clicking "start" for a ticket
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
      | user_username | project_name |
      | tester        | Test project |
    And the following user roles:
      | user_username | ticket_name | worker |
      | tester        | Test ticket | true   |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "start" for the "Test ticket" ticket
    Then I should see "Test ticket" within "#current-ticket"

  Scenario: It should display my open ticket if I have one
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following ticket records:
      | name        |
      | Test ticket |
    And the following ticket times:
      | worker_username | ticket_name |
      | tester          | Test ticket |
    When I log in as "tester"
    Then I should see "Test ticket" within "#current-ticket"

  Scenario: I should not see another worker's open ticket at the top
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
    And the following ticket records:
      | name         |
      | Other ticket |
    And the following ticket times:
      | worker_username | ticket_name  |
      | other           | Other ticket |
    When I log in as "tester"
    Then I should not see "Other ticket" within "#current-ticket"

  @javascript
  Scenario: If I try to start a new ticket and the open ticket has a start time in the future, I should see a validation errror
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
      | user_username | project_name |
      | tester        | Test project |
    And the following user roles:
      | user_username | ticket_name | worker |
      | tester        | Test ticket | true   |
    And the following ticket times:
      | worker_username | ticket_name | started_at |
      | tester          | Test ticket | 2999-01-01 |
    When I log in as "tester"
    And I follow "projects"
    And I follow "tickets" for the "Test project" project
    And I follow "start" for the "Test ticket" ticket
    Then I should see "Worker has a currently open ticket time with a future start date. Please close it before opening a new ticket."

  @javascript
  Scenario: If I stop a current ticket time, it should disappear from the current-ticket box
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following ticket records:
      | name        |
      | Test ticket |
    And the following ticket times:
      | worker_username | ticket_name |
      | tester          | Test ticket |
    When I log in as "tester"
    And I press "Stop now"
    Then I should not see "Test ticket" within "#current-ticket"

  @javascript
  Scenario: I should be able to start my best available ticket straight from the panel
    Given the following worker records:
      | username |
      | tester   |
    And all tickets for "tester" are closed
    And the following tickets:
      | name        |
      | Test ticket |
    And the following user roles:
      | user_username | ticket_name | worker |
      | tester        | Test ticket | true   |
    When I log in as "tester"
    And I am on the panel page
    And I follow "start"
    Then I should see "Test ticket" within "#current-ticket"

  Scenario: I should be able to get to the ticket times index page if I have ticket times
    Given the following worker records:
      | username |
      | tester   |
    And the following tickets:
      | name        |
      | Test ticket |
    And the following ticket times:
      | worker_username | ticket_name | started_at_minutes_ago | ended_at_minutes_ago |
      | tester          | Test ticket | 60                     | 30                   |
    When I log in as "tester"
    And I follow "Manage times"
    Then I should see "Test ticket"

  Scenario: I should not see a link to the ticket times index page if I don't have times
    Given the following worker records:
      | username |
      | tester   |
    When I log in as "tester"
    Then I should not see "Manage times"

  Scenario: I should not see other users' times
    Given the following worker records:
      | username |
      | tester   |
      | other    |
    And the following tickets:
      | name         |
      | Test ticket  |
      | Other ticket |
    And the following ticket times:
      | worker_username | ticket_name  | started_at_minutes_ago | ended_at_minutes_ago |
      | tester          | Test ticket  | 60                     | 30                   |
      | other           | Other ticket | 60                     | 30                   |
    When I log in as "tester"
    And I follow "Manage times"
    Then I should not see "Other ticket"

  Scenario: Times should show in reverse chronological order
    Given the following worker records:
      | username |
      | tester   |
    And the following tickets:
      | name          |
      | Middle ticket |
      | First ticket  |
      | Last ticket   |
    And the following ticket times:
      | worker_username | ticket_name   | started_at_minutes_ago | ended_at_minutes_ago |
      | tester          | Last ticket   | 60                     | 30                   |
      | tester          | First ticket  | 120                    | 90                   |
      | tester          | Middle ticket | 90                     | 60                   |
    When I log in as "tester"
    And I follow "Manage times"
    Then I should see the following text in order:
      | text          |
      | Last ticket   |
      | Middle ticket |
      | First ticket  |

  Scenario: I should see "NOW" in the ended at place if the ticket is ongoing
    Given the following worker records:
      | username |
      | tester   |
    And the following tickets:
      | name        |
      | Test ticket |
    And the following ticket times:
      | worker_username | ticket_name | started_at_minutes_ago |
      | tester          | Test ticket | 60                     |
    When I log in as "tester"
    And I follow "Manage times"
    Then I should see " - NOW"

  Scenario: I should be able to edit the ticket time times
    Given the following worker records:
      | username |
      | tester   |
    And the following tickets:
      | name        |
      | Test ticket |
    And the following ticket times:
      | worker_username | ticket_name | started_at          | ended_at            |
      | tester          | Test ticket | 2010-01-01 02:02:02 | 2010-01-01 03:03:03 |
    When I log in as "tester"
    And I follow "Manage times"
    And I follow "edit"
    And I select "2010" from "ticket_time_started_at_1i"
    And I select "January" from "ticket_time_started_at_2i"
    And I select "1" from "ticket_time_started_at_3i"
    And I select "1" from "ticket_time_started_at_4i"
    And I select "1" from "ticket_time_started_at_5i"
    And I select "1" from "ticket_time_started_at_6i"
    And I press "Update ticket time"
    And I follow "Manage times"
    Then I should see "2010-01-01 01:01:01"

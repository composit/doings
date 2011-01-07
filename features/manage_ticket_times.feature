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

  @javascript @current
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

  @javascript @current
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

  @javascript @current
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

Feature: manage ticket times

  @javascript
  Scenario: I should not see the "start" link for a ticket if I am not a worker for that ticket
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following project records:
      | name         |
      | Test project |
    And the following tickets:
      | name        | project_name |
      | Test ticket | Test project |
    And the following user roles:
      | user_username | project_name | worker |
      | tester        | Test project | true   |
    And the following user roles:
      | user_username | ticket_name |
      | tester        | Test ticket |
    When I log in as "tester"
    And I am on the projects page
    And I follow "tickets" for the "Test project" project
    Then I should see "Test ticket"
    And I should not see "start"

  @javascript
  Scenario: I should be able to create a new ticket time by clicking "start" for a ticket
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following project records:
      | name         |
      | Test project |
    And the following tickets:
      | name        | project_name |
      | Test ticket | Test project |
    And the following user roles:
      | user_username | project_name |
      | tester        | Test project |
    And the following user roles:
      | user_username | ticket_name | worker |
      | tester        | Test ticket | true   |
    When I log in as "tester"
    And I am on the projects page
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

  Scenario: If I start a new ticket time and one is already open, it should close the open one at the current time
    pending

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

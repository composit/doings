Feature: manage users

  Scenario: When I log in, the time zone should reflect my time zone
    Given the following confirmed_user records:
      | username | time_zone                   |
      | tester   | Central Time (US & Canada)  |
      | tester2  | Mountain Time (US & Canada) |
    When I log in as "tester"
    Then the time zone should be "(GMT-06:00) Central Time (US & Canada)"
    When I log in as "tester2"
    Then the time zone should be "(GMT-07:00) Mountain Time (US & Canada)"

  Scenario: When I log in, I should be on my panel
    When I log in as "tester"
    Then I should see "Panel"

  Scenario: I should be able to log out
    When I log in as "tester"
    And I follow "Sign out"
    Then I should be on the new user session page

  Scenario: I should be able to get to my panel through the sidebar link
    When I log in as "tester"
    And I am on the projects page
    And I follow "Panel"
    Then I should be on the panel page

  Scenario: When am on my panel, I should see the percent completed today if I am a worker and have goals
    Given the following worker records:
      | username |
      | tester   |
    And the following goals:
      | user_username | units   | amount | period | relative_weekday |
      | tester        | minutes | 60     | Daily  | today            |
    And the following ticket times:
      | worker_username | started_at_minutes_ago |
      | tester          | 30                     |
    When I log in as "tester"
    And I am on the panel page
    Then I should see "s goals are 50% complete"

  Scenario: When I am on my panel, I should not see a percent completed today if I am not a worker
    When I log in as "tester"
    And I am on the panel page
    Then I should not see "s goals are"

  Scenario: When I am on my panel, I should not see a percent completed today if I do not have goals
    Given the following worker records:
      | username |
      | tester   |
    And the following ticket times:
      | worker_username | started_at_minutes_ago |
      | tester          | 30                     |
    When I log in as "tester"
    And I am on the panel page
    Then I should not see "s goals are"

  Scenario: When I am on my panel, I should see my best available ticket
    Given the following worker records:
      | username |
      | tester   |
    When I log in as "tester"
    Then I should see "Best available ticket:"

  Scenario: When I am on my panel, I should see "No available tickets" if I do not have open tickets
    Given the following worker records:
      | username |
      | tester   |
    And all tickets for "tester" are closed
    When I log in as "tester"
    Then I should see "No available tickets"

  Scenario: I should not see my best available ticket on my panel if I am not a worker
    When I log in as "tester"
    And I am on the panel page
    Then I should not see "Best available ticket:"
    And I should not see "No available tickets"

  Scenario: I should be able to redefine my workweek
    Given the following worker records:
      | username |
      | tester   |
    When I log in as "tester"
    And I follow "Manage goals"
    And I uncheck "Tuesday" 
    And I uncheck "Thursday"
    And I press "Update workweek"
    And I am on the goals page
    Then the "Sunday" checkbox should not be checked
    Then the "Monday" checkbox should be checked
    Then the "Tuesday" checkbox should not be checked
    Then the "Wednesday" checkbox should be checked
    Then the "Thursday" checkbox should not be checked
    Then the "Friday" checkbox should be checked
    Then the "Saturday" checkbox should not be checked

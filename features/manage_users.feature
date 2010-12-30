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

  @javascript @current
  Scenario: When am on my panel, I should see the percent completed today
    Given the following worker records:
      | username | confirmed_at  |
      | tester   | 2010-12-30    |
    And the following goals:
      | user_username | units   | amount |
      | tester        | minutes | 60     |
    And the following ticket times:
      | worker_username | started_at_minutes_ago |
      | tester          | 30                     |
    When I log in as "tester"
    And I am on the panel page
    Then I should see "50%"

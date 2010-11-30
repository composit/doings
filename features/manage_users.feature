Feature: manage users

  Scenario: When I log in, the time zone should reflect my time zone
    Given the following confirmed_user records:
      | username | time_zone                   |
      | tester   | Central Time (US & Canada)  |
      | tester2  | Mountain Time (US & Canada) |
    When I am logged in as "tester"
    Then the time zone should be "(GMT-06:00) Central Time (US & Canada)"
    When I am logged in as "tester2"
    Then the time zone should be "(GMT-07:00) Mountain Time (US & Canada)"

  Scenario: When I log in, I should be on the projects index page
    When I am logged in as "tester"
    Then I should see "Projects"

  Scenario: When I log in as a worker, I should be on the current ticket page
    Given the following confirmed_user records:
      | username |
      | tester   |
    Given the following user roles:
      | user_username | worker |
      | tester        | true   |
    When I am logged in as "tester"
    Then I should be on the current tickets page

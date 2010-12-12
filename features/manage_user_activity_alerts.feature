Feature: manage user activity alerts
  
  Scenario: I should see all undismissed alerts
    Given the following confirmed_user records:
      | username |
      | tester   |
    And the following user activity alerts:
      | user_username | content           |
      | tester        | This is an alert! |
    When I log in as "tester"
    Then I should see "This is an alert!"

  Scenario: I should not see other users' alerts
    Given the following confirmed_user records:
      | username |
      | tester   |
      | other    |
    And the following user activity alerts:
      | user_username | content           |
      | other         | This is an alert! |
    When I log in as "tester"
    Then I should not see "This is an alert!"

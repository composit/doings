Feature: manage goals

  Scenario: I should be able to get to the update goals page through the side panel link
    Given the following worker records:
      | username |
      | tester   |
    When I log in as "tester"
    And I follow "Update goals"
    Then I should be on the goals page

  Scenario: I should not see a side panel link for updating goals if I am not a worker
    Given the following confirmed_user records:
      | username |
      | tester   |
    When I log in as "tester"
    Then I should not see "Update goals"

  @javascript
  Scenario: I should be able to add new goals
    Given the following worker records:
      | username |
      | tester   |
    When I log in as "tester"
    And I am on the goals page
    And I follow "new goal"
    And I fill in "Name" with "Test goal"
    And I select "Yearly" from "Period"
    And I fill in "Amount (minutes/dollars)" with "1"
    And I press "Create goal"
    And I am on the goals page
    Then I should see "Test goal"

  Scenario: I should see an alert if I enter an invalid goal
    pending

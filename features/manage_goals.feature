Feature: manage goals

  Scenario: I should be able to get to the update goals page through the side panel link
    Given the following worker records:
      | username |
      | tester   |
    When I log in as "tester"
    And I follow "Manage goals"
    Then I should be on the goals page

  Scenario: I should not see a side panel link for updating goals if I am not a worker
    Given the following confirmed_user records:
      | username |
      | tester   |
    When I log in as "tester"
    Then I should not see "Manage goals"

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

  @javascript
  Scenario: I should see an alert if I enter an invalid goal
    Given the following worker records:
      | username |
      | tester   |
    When I log in as "tester"
    And I am on the goals page
    And I follow "new goal"
    And I press "Create goal"
    Then I should see "t be blank"

  @javascript
  Scenario: I should be able to select a workable object
    Given the following worker records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | worker |
      | tester        | Test client | true   |
    When I log in as "tester"
    And I am on the goals page
    And I follow "new goal"
    And I fill in "Name" with "Test goal"
    And I select "Client" from "Workable type (optional)"
    Then I should see "Test client" within "#new-goal-form"
    When I select "Test client" from "Workable"
    And I select "Yearly" from "Period"
    And I fill in "Amount (minutes/dollars)" with "2"
    And I press "Create goal"
    And I am on the goals page
    Then I should see "Test goal: 2 minutes/year for Test client"

  @javascript
  Scenario: I should not be able to select a workable object I am not a worker for
    Given the following worker records:
      | username |
      | tester   |
    And the following client records:
      | name        |
      | Test client |
    And the following user roles:
      | user_username | client_name | worker |
      | tester        | Test client | false  |
    When I log in as "tester"
    And I am on the goals page
    And I follow "new goal"
    And I select "Client" from "Workable type"
    Then I should not see "Test client" within "#new-goal-form"

  @javascript
  Scenario: I should not be able to select a closed project
    Given the following worker records:
      | username |
      | tester   |
    And the following project records:
      | name         | closed_at           |
      | Test project | 2001-01-01 01:01:01 |
    And the following user roles:
      | user_username | project_name | worker |
      | tester        | Test project | true   |
    When I log in as "tester"
    And I am on the goals page
    And I follow "new goal"
    And I select "Project" from "Workable type"
    Then I should not see "Test project" within "#new-goal-form"

  @javascript
  Scenario: I should not be able to select a closed ticket
    Given the following worker records:
      | username |
      | tester   |
    And the following ticket records:
      | name        | closed_at           |
      | Test ticket | 2001-01-01 01:01:01 |
    And the following user roles:
      | user_username | ticket_name | worker |
      | tester        | Test ticket | true   |
    When I log in as "tester"
    And I am on the goals page
    And I follow "new goal"
    And I select "Ticket" from "Workable type"
    Then I should not see "Test ticket" within "#new-goal-form"

  @javascript
  Scenario: I should not see a weekday option when creating a non-daily goal
    Given the following worker records:
      | username |
      | tester   |
    When I log in as "tester"
    And I am on the goals page
    And I follow "new goal"
    Then "Weekday" should not be visible

  @javascript
  Scenario: I should be able to set the weekday for daily goals
    Given the following worker records:
      | username |
      | tester   |
    When I log in as "tester"
    And I am on the goals page
    And I follow "new goal"
    And I fill in "Name" with "Test goal"
    And I select "Daily" from "Period"
    And I select "Tuesday" from "Weekday"
    And I fill in "Amount (minutes/dollars)" with "1"
    And I press "Create goal"
    And I am on the goals page
    Then I should see "Test goal"

  @javascript
  Scenario: I should be able to delete goals
    Given the following worker records:
      | username |
      | tester   |
    And the following goals:
      | user_username | name       |
      | tester        | Test goal  |
      | tester        | Other goal |
    When I log in as "tester"
    And I am on the goals page
    And I am prepared to confirm a popup dialog
    And I follow "delete" for the "Test goal" goal
    Then I should not see "Test goal"
    And I should see "Other goal"

  Scenario: I should be able to reprioritize goals
    Given the following worker records:
      | username |
      | tester   |
    And the following goals:
      | user_username | name       | priority |
      | tester        | Goal one   | 1        |
      | tester        | Goal two   | 2        |
      | tester        | Goal three | 3        |
    When I log in as "tester"
    And I am on the goals page
    And I fill in "2" for the "Goal one" goal priority
    And I fill in "3" for the "Goal two" goal priority
    And I fill in "1" for the "Goal three" goal priority
    And I press "Reprioritize"
    Then I should see the following text in order:
      | text       |
      | Goal three |
      | Goal one   |
      | Goal two   |

  @javascript @current
  Scenario: I should be able to see my daily goals
    Given the following worker records:
      | username |
      | tester   |
    And the following goals:
      | user_username | name       | priority | units   | amount | period | relative_weekday |
      | tester        | Goal one   | 1        | minutes | 100    | Daily  | today            |
      | tester        | Goal two   | 2        | dollars | 50     | Daily  | today            |
    When I log in as "tester"
    And I am on the panel page
    And I follow "view daily goals"
    Then I should see "Goal one: 0/100 minutes"
    And I should see "Goal two: 0/50 dollars"
    And I should see "100 minutes to go"
    And I should see "50 dollars to go"

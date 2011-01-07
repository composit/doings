Feature: manage billing rates

  @javascript
  Scenario: I should not see the estimated hourly rate field if my rate is hourly
    When I log in as "tester"
    And I follow "New client"
    And I select "hour" from "per"
    Then "Estimated hourly rate" should not be visible

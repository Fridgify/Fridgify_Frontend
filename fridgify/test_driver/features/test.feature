Feature: Counter increases
  Counter increases when button is pressed

  Scenario: Counter pressed once
    Given I expect the "counter" to be "0"
    When I tap the tooltip "Increment" button once
    Then I expect the "counter" to be "1"

  Scenario: Counter increases
    When I tap the tooltip "Increment" button 10 times
    Then I expect the "counter" to be "10"
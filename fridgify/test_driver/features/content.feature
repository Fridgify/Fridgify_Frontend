Feature: Content Screen
  The User is on the fridge content screen

  Scenario: See the content
    Given I see screen "fridge"
    Then I have 5 items

  Scenario: See content info
    Given I see screen "fridge"
    When I tap the "milk" label
    Then I see popup "milkInfo"

  Scenario: I swipe left on item
    Given I see screen "fridge"
    And I see content "milk" is 1000
    When I swipe left on "milk" 20 %
    Then I see content "milk" is 800

  Scenario: I swipe left on item to empty
    Given I see screen "fridge"
    And I see content "milk" is 1000
    When I swipe left on "milk" 100 %
    Then I see popup "milkEmpty"

  Scenario: I add item manual
    Given I see screen "fridge"
    When I tap the "manual" button
    Then I see dropdown "addItem"

  Scenario: I add item with scan
    Given I see screen "fridge"
    When I tap the "scan" button
    Then I see screen "scan"
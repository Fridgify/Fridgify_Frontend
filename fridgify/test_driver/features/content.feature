Feature: Content Screen
  The User is on the fridge content screen

  Scenario: I add item manual
    Given I see screen "fridge"
    When I tap the "manual" button
    Then I see dropdown "addItem"

  Scenario: I add item with scan
    Given I see screen "fridge"
    When I tap the "scan" button
    Then I see screen "scan"

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

  Scenario: See the content
    Given I see screen "fridge"
    Then I have 5 items

  Scenario: See content info
    Given I see screen "fridge"
    When I tap the "milk" label
    Then I see popup "milkInfo"

  Scenario: Remove Item manually - Verification
    Given user is authenticated for fridge
    And fridge is not empty
    And chosen item exists
    When user changes item volume of chosen item to zero
    Then show message box asking if user is sure to remove item

  Scenario: Remove Item manually - Confirmed
    Given user is authenticated for fridge
    And fridge is not empty
    And chosen item exists
    And verification message box is shown
    When user confirmes removal
    Then send delete task to backend
    Then redirect to "Content Overview"-Page
    Then update list

  Scenario: Remove Item manually - Canceled
    Given user is authenticated for fridge
    And fridge is not empty
    And chosen item exists
    And verification message box is shown
    When selects "Cancel"
    Then close message box
    And set volume to value before change

  Scenario: Remove Item automatically (expired)
    Given item exists
    And fridge is no empty
    When item expired
    Then send notification to user - "Item A expired"
    And send delete action to backend
    And update cached list if necessary
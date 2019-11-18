Feature: Overview Screen
  The User is on the Fridge Overview Screen

  Scenario: The User opens a Fridge
    Given I see "overview"
    When I click the fridge
    Then I see screen "fridge"

  Scenario: The User opens Fridge Menu
    Given I see "overview"
    When I hold the fridge for 3 seconds
    Then I expect update "fMenu"

  Scenario: The User shares Fridge
    Given I see "overview"
    When I hold the "fridge" for 3 seconds
    And I tap the "share" label
    Then I see popup "qr"

  Scenario: The User edits Fridge
    Given I see "overview"
    When I hold the fridge for 3 seconds
    And I tap the "edit" label
    Then I see popup "edit"

  Scenario: The User deletes Fridge
    Given I see "overview"
    When I hold the fridge for 3 seconds
    And I tap the "delete" label
    Then I see popup "delete"

  Scenario: The User Joins Fridge
    Given I see "overview"
    When I tap the "join" label
    Then I see screen "join"

  Scenario: The User Creates a Fridge
    Given I see "overview"
    When I tap the "new" label
    Then i see popup "new"
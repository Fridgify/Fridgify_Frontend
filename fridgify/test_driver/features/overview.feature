Feature: Overview Screen
  The User is on the Fridge Overview Screen

  Scenario: The User Joins Fridge
    Given I see "overview"
    When I tap the"join" label
    Then I see screen "join"

  Scenario: The User Creates a Fridge
    Given I see "overview"
    When I tap the "new" label
    Then i see popup "new"

  Scenario: The User opens a Fridge
    Given I see "overview"
    When I click the fridge
    Then I see screen "fridge"

  Scenario: The User opens Fridge Menu
    Given I see "overview"
    When I hold the fridge for 3 seconds
    Then I expect update "fMenu"

  Scenario: The User manages member
    Given I see "ooverview"
    When I click the fridge_member
    Then I see screen "user_management_screen"

  Scenario: The User deletes Fridge
    Given I see "overview"
    When I hold the fridge for 3 seconds
    And I tap the "delete" label
    Then I see popup "delete"
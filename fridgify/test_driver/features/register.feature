Feature: Register Screen
  The user is on the register screen and signs up

  Scenario: The User registers successfully
    Given I see "register"
    And I enter valid "email"
    And I enter valid "password"
    And I enter valid "repeatPassword"
    When I tap the "register" button
    Then I see screen "overview"

  Scenario: The User enters used email
    Given I see "register"
    And I enter used "email"
    And I enter valid "password"
    And I enter valid "repeatPassword"
    When I tap the "register" button
    Then I see popup "mail exists"

  Scenario: The User enters wrong password
    Given I see "register"
    And I enter valid "email"
    And I enter valid "password"
    And I enter dummy "repeatPassword"
    When I tap the "register" button
    Then I see popup "password no match"

  Scenario: The User wants to login
    Given I see "register"
    When I tap the "login" label
    Then I see screen "login"
Feature: Login Screen
  The User is on the login screen and logs in

  Scenario: The User logs in successful
    Given I see "login"
    And I enter a valid "email"
    And I enter a valid "password"
    When I tap the "login" button
    Then I see screen "overview"

  Scenario: The User logs in not successful
    Given I see "login"
    And I enter a dummy "email"
    And I enter a dummy "password"
    When I tap the "login" button
    Then I see popup "wrongData"

  Scenario: The User wants to create an account
    Given I see "login"
    When I tap the "register" label
    Then I see screen "register"

  Scenario: The User forgets his password
    Given I see "login"
    When I tap the "forgotPassword" label
    Then I see screen "forgotPassword"
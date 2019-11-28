Feature: Login Screen
  The User is on the login screen and logs in

  Scenario: The User logs in not successful
    Given I see screen "login_screen"
    When I fill the "emailfield" field with "invalid@dummy.com"
    And I fill the "passfield" field with "dummypass"
    Then I tap the "login_btn" button
    And I see screen "login"

  Scenario: The User forgets his password
    Given I see screen "login"
    Then I tap the "forgot_lbl" label
    And I see screen "forgotPassword"

  Scenario: The User logs in successful
    Given I see screen "login_screen"
    When I fill the "emailfield" field with "valid@dummy.com"
    And I fill the "passfield" field with "dummypass"
    Then I tap the "login_btn" button
    And I see screen "overview"

  Scenario: The User wants to create an account
    Given I see screen "login_screen"
    When I tap the "register_lbl" label
    Then I see screen "register_screen"

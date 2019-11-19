Feature: Register Screen
  The user is on the register screen and signs up


  Scenario: The User enters used email
    Given I see screen "register_screen"
    When I tap the "register_lbl" label
    And I fill the "emailfield" field with "invalid@dummy.com"
    And I fill the "passfield" field with "dummypass"
    And I fill the "rep_passfield" field with "dummypass"
    Then I tap the "register_btn" button
    And I see popup "mail exists"

  Scenario: The User enters wrong password
    Given I see screen "register_screen"
    When I tap the "register_lbl" label
    And I fill the "emailfield" field with "invalid@dummy.com"
    And I fill the "passfield" field with "dummypass" "dummypass"
    And I fill the "rep_passfield" field with "dummypass1"
    Then I tap the "register_btn" button
    And I see popup "password don't match"

  Scenario: The User registers successfully
    Given I see screen "register_screen"
    When I tap the "register_lbl" label
    And I fill the "emailfield" field with "invalid@dummy.com"
    And I fill the "passfield" field with "dummypass"
    And I fill the "rep_passfield" field with "dummypass"
    Then I tap the "register_btn" button
    And I see screen "overview"

  Scenario: The User wants to login
    Given I see screen "register_screen"
    When I tap the "register_lbl" label
    And I tap the "login_lbl" label
    And I tap the "login" label
    Then I see screen "login_screen"

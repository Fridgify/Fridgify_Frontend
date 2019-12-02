Feature: Login Screen
  The User is on the login screen and logs in

  Scenario: The User registers unsuccessfully
    Given I see screen "login_screen"
    When I tap the "register_lbl" label
    And I fill the "usernamefield" field with "dummy"
    And I fill the "emailfield" field with "valid@dummy.com"
    And I fill the "passfield" field with "dummypass"
    And I fill the "rep_passfield" field with "dummypass"
    Then I tap the "register_btn" button
    And I see screen "overview"

  Scenario: The User logs in successful
    Given I see screen "login_screen"
    When I fill the "emailfield" field with "dummy"
    And I fill the "passfield" field with "dummypass"
    Then I tap the "login_btn" button
    And I see screen "login"


  Scenario: The User Creates a Fridge
    Given I see screen "overview""
    Then I tap the "AddPopup" button
    When I fill the "f_name" field with "fridgeName"
    And I fill the "f_desc" field with "fridgeDesc"
    Then I tap the "addFBtn" button
    And I see screen "overview"


  Scenario: The User opens a Fridge
    Given I see screen "overview"
    Then I tap the "fridgeBtn" button
    Then I see screen "content"


  Scenario: I add item manual
    Given I see screen "overview"
    When I tap the "fridgeBtn" button
    And I tap the "add_content" button
    Then I see screen "addItem"
    And I fill the "name" field with "milk"
    And I fill the "store" field with "lidl"
    And I fill the "desc" field with "ja milk"
    And I fill the "amount" field with "1000"
    And I fill the "unit" field with "ml"
    And I fill the "exp" field with "2020-01-01"
    And I tap the "add_con" button


  Scenario: I remove item manual
    Given I see screen "overview"
    When I tap the "fridgeBtn" button
    And I tap the "milk" button
    Then I see screen "delPopup"
    And I tap the "removeButton" button
    And I see screen "content"

Feature: Content Screen
  The User is on the fridge content screen

  Scenario: I add item manual
    Given I see screen "content"
    When I tap the "fridgeBtn" button
    Then I see screen "addItem"
    And I fill the "name" field with "milk"
    And I fill the "store" field with "lidl"
    And I fill the "desc" field with "ja milk"
    And I fill the "amount" field with "1000"
    And I fill the "unit" field with "ml"
    And I fill the "exp" field with "2020-01-01"
    And I tap the "add_con" button


  Scenario: I remove item manual
    Given I see screen "content"
    When I tap the "milk" button
    Then I see screen "delPopup"
    And I tap the "removeButton"
    And I see screen "content"
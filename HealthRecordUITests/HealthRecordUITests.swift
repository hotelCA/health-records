//
//  HealthRecordUITests.swift
//  HealthRecordUITests
//
//  Created by Quoc Anh Tran on 7/9/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import XCTest

class HealthRecordUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchEnvironment = ["TEST" : "true"]
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {

        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSelectingRows() {
        
        let tablesQuery = XCUIApplication().tables
        tablesQuery.staticTexts["Day: 1974-09-07 00:01:19 +0000"].tap()
        tablesQuery.staticTexts["Year: 1974-09-07 00:01:19 +0000"].tap()
        
        let year1973 = tablesQuery.staticTexts["Year: 1973-12-11 00:01:07 +0000"]
        year1973.tap()
        tablesQuery.staticTexts["Day: 1973-12-11 00:01:07 +0000"].tap()
        tablesQuery.children(matching: .cell).element(boundBy: 4).staticTexts["Day: pain"].tap()
        year1973.tap()
        
        let year1970 = tablesQuery.staticTexts["Year: 1970-12-27 00:00:19 +0000"]
        year1970.tap()
        tablesQuery.staticTexts["Day: 1970-09-28 00:00:15 +0000"].tap()
        
        let contentRow = tablesQuery.children(matching: .cell).element(boundBy: 7).children(matching: .staticText).element
        contentRow.tap()
        contentRow.tap()
        year1970.tap()
    }

    func testRemovingRows() {

    }
    
}

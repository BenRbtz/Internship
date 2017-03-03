//
//  securePortalTests.swift
//  securePortalTests
//
//  Created by Ben Roberts on 17/06/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import XCTest
@testable import securePortal

class securePortalTests: XCTestCase {
    var loginVC: UIViewController?
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "loginVC", bundle: NSBundle.mainBundle())
        loginVC = storyboard.instantiateInitialViewController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}

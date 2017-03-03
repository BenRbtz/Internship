//
//  ContactUsVCTest.swift
//  securePortal
//
//  Created by Ben Roberts on 09/08/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit
import XCTest
import MessageUI
@testable import securePortal

class ContactUsVCTest: XCTestCase {
    class ViewControllerMock: ContactUsVC {
        var viewControllerToPresent: UIViewController?
        var segueIdentifier: NSString?
        
        override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
            self.viewControllerToPresent = viewControllerToPresent
        }
    }
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPopUpAlert() {
        let controller = ViewControllerMock()
        
        XCTAssertNil(controller.viewControllerToPresent , "Before view loads should be nil")
        
        controller.popUpAlert()
        
        if let alert = controller.viewControllerToPresent as? UIAlertController {
            XCTAssertEqual("Could Not Send Email", alert.title!)
            XCTAssertEqual("Please check e-mail configuration and try again.", alert.message!)
        } else {
            XCTFail("UIAlertController failed to be presented")
        }
    }
    
    func testDisplayEmail() {
        let controller = ViewControllerMock()
        
        XCTAssertNil(controller.viewControllerToPresent , "Before view loads should be nil")
        
        controller.displayEmail("", messageBody: "", recipents: [""])
       
        XCTAssertNotNil(controller.viewControllerToPresent , "Mail view should be present")
    }
    
    func testNavLogo() {
        let controller = ViewControllerMock()
        
        XCTAssertNil(controller.navigationItem.titleView , "Before view loads should be nil")
        
        controller.navLogo()
        
        XCTAssertNotNil(controller.navigationItem.titleView , "Should not be nil after loading of logo")
    }
    
}

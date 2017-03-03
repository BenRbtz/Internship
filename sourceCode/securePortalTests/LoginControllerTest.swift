//
//  LoginController.swift
//  securePortal
//
//  Created by Ben Roberts on 08/08/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit
import XCTest
@testable import securePortal

class LoginControllerTest: XCTestCase {
    class ViewControllerMock: LoginVC {
        var viewControllerToPresent: UIViewController?
        var segueIdentifier: NSString?
        
        override func performSegueWithIdentifier(identifier: String?, sender: AnyObject?) {
            segueIdentifier = identifier
        }
        
        override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
            self.viewControllerToPresent = viewControllerToPresent
        }
    }
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShowAlert() {
        let controller = ViewControllerMock()
        
        XCTAssertNil(controller.viewControllerToPresent , "Before view loads should be nil")
        
        controller.showAlert(.EmptyFields)
        if let alert = controller.viewControllerToPresent as? UIAlertController {
            XCTAssertEqual("Error", alert.title!)
            XCTAssertEqual("Both fields empty.", alert.message!)
        } else {
            XCTFail("UIAlertController failed to be presented")
        }
        
        controller.showAlert(.EmptyUsername)
        if let alert = controller.viewControllerToPresent as? UIAlertController {
            XCTAssertEqual("Error", alert.title!)
            XCTAssertEqual("Empty username field.", alert.message!)
        } else {
            XCTFail("UIAlertController failed to be presented")
        }
        
        controller.showAlert(.EmptyPassword)
        if let alert = controller.viewControllerToPresent as? UIAlertController {
            XCTAssertEqual("Error", alert.title!)
            XCTAssertEqual("Empty password field.", alert.message!)
        } else {
            XCTFail("UIAlertController failed to be presented")
        }
        
        controller.showAlert(.InvalidCredentials)
        if let alert = controller.viewControllerToPresent as? UIAlertController {
            XCTAssertEqual("Error", alert.title!)
            XCTAssertEqual("Invalid username or password.", alert.message!)
        } else {
            XCTFail("UIAlertController failed to be presented")
        }
        
        controller.showAlert(.NetworkFailure)
        if let alert = controller.viewControllerToPresent as? UIAlertController {
            XCTAssertEqual("No Internet Connection", alert.title!)
            XCTAssertEqual("Make sure your device is connected to the internet.", alert.message!)
        } else {
            XCTFail("UIAlertController failed to be presented")
        }
    }
    
    func testDoLogin() {

        let controller = ViewControllerMock()
        
        XCTAssertNil(controller.viewControllerToPresent , "Before view loads should be nil")
        
        controller.doLogin("", password: "")
        if let alert = controller.viewControllerToPresent as? UIAlertController {
            XCTAssertEqual("Error", alert.title!)
            XCTAssertEqual("Both fields empty.", alert.message!)
        } else {
            XCTFail("UIAlertController failed to be presented")
        }
        
        controller.doLogin("", password: "B")
        if let alert = controller.viewControllerToPresent as? UIAlertController {
            XCTAssertEqual("Error", alert.title!)
            XCTAssertEqual("Empty username field.", alert.message!)
        } else {
            XCTFail("UIAlertController failed to be presented")
        }
        
        controller.doLogin("B", password: "")
        if let alert = controller.viewControllerToPresent as? UIAlertController {
            XCTAssertEqual("Error", alert.title!)
            XCTAssertEqual("Empty password field.", alert.message!)
        } else {
            XCTFail("UIAlertController failed to be presented")
        }
        
        controller.doLogin("S", password: "S")
        if let alert = controller.viewControllerToPresent as? UIAlertController {
            XCTAssertEqual("Error", alert.title!)
            XCTAssertEqual("Invalid username or password.", alert.message!)
        } else {
            XCTFail("UIAlertController failed to be presented")
        }
        
        controller.doLogin("B", password: "B")
        if let identifier = controller.segueIdentifier {
            XCTAssertEqual("main", identifier)
        } else {
            XCTFail("Segue should be performed")
        }
    }
    
    func testNavLogo() {
        let controller = ViewControllerMock()
        
        XCTAssertNil(controller.navigationItem.titleView , "Before view loads should be nil")
        
        controller.navLogo()
        
        XCTAssertNotNil(controller.navigationItem.titleView , "Should not be nil after loading of logo")
    }
    
    func testLoginButton() {
        class ViewControllerMock: LoginVC {
            var doLoginCalled = false
            
            override func doLogin(username: String, password: String) {
                doLoginCalled = true
            }
            override private func loginButton(sender: AnyObject) {
                doLogin("",password: "")
            }
        }
        
        let controller = ViewControllerMock()
        
        let loginButton = UIButton()
        loginButton.addTarget(controller, action: #selector(LoginVC.loginButton(_:)), forControlEvents: .TouchDown)
        loginButton.sendActionsForControlEvents(.TouchDown)
        
        XCTAssert(controller.doLoginCalled, "doLogin method should be called")
    }
}

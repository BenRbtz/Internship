//
//  LoginController.swift
//  securePortal
//
//  Created by Ben Roberts on 20/06/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit
import CoreData

class LoginVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginSpinner: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    /**
        Contains the different errors that can occur
         - EmptyFields: Both Email and password cell are empty
         - EmptyUsername: Username field is empty
         - EmptyPassword: Passsword field is empty
         - InvalidCredentials: Username or password field has been entered incorrectly
         - NetworkFailure: Unable to connect to the internet
     */
    enum popAlertTypes {case emptyFields, emptyUsername, emptyPassword, invalidCredentials, networkFailure}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navLogo()
        dismissKeyboardGesture()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Sets the center of the navigation bar to the secure trading logo
    func navLogo(){
        let image = UIImage(named: "st_logo-white-trans-big-notag") // gets image
        let imageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 25, height: 35)) // set view size
        imageView.contentMode = .scaleAspectFit // scale aspect fit for view
        imageView.image = image // inserts image into view
        self.navigationItem.titleView = imageView // inserts into navigation bar
    }
    
    /// Moves textfields up
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if UIDevice.current.userInterfaceIdiom != .pad {
            if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
                animateViewMoving(true, moveValue: 50)
            }
        }
    }
    
    /// Move textfield down
    func textFieldDidEndEditing(_ textField: UITextField) {
        if UIDevice.current.userInterfaceIdiom != .pad {
            if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
                animateViewMoving(false, moveValue: 50)
            }
        }
    }
    
    /**
        Move the view based up/down
        - parameters:
            - up: Whether to move the view up or down.
            - moveValue: Amount the view should be moved.
    */
    func animateViewMoving(_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    /** 
        Makes pressing enter switch from username field to password field.
        When in the password field and press enter, it will attempt to login.
        - parameters:
            - textField : Current selected textfield object.
    */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //switches textfields
        let nextTag = textField.tag + 1 as Int
        let nextField: UIResponder? = textField.superview?.viewWithTag(nextTag)
        
        loginSpinner.startAnimating() // starts spinning animation
        // If username field selected
        if let field: UIResponder = nextField {
            field.becomeFirstResponder() // sets as first responder
        }
        else
        {
            textField.resignFirstResponder() // resign as first responder
            doLogin(usernameTextField.text!, password: passwordTextField.text!) //check credentials
        }
        loginSpinner.stopAnimating() //stops spinning animation
        return false
    }

    /// Enables tap-gesture to dismiss keyboard upon tapping the view.
    func dismissKeyboardGesture() {
        let tapper = UITapGestureRecognizer(target: view, action:#selector(UIView.endEditing))
        tapper.cancelsTouchesInView = false
        tapper.delegate = self
        view.addGestureRecognizer(tapper)
    }
    /**
        Checks the username and password whether its correct.
        If it's correct it will segue to the MainView View Controller,
        otherwise it will call the showAlert method.
         - parameters:
             - username : Username.
             - password : Password.
     */
    func doLogin(_ username: String, password: String){
        // Check if fields and occupied
        if Reachability.isConnectedToNetwork() == true {
            if username.isEmpty || password.isEmpty {
                if username.isEmpty && password.isEmpty {
                    showAlert(.emptyFields)
                    
                } else if username.isEmpty {
                    showAlert(.emptyUsername)
                } else {
                    showAlert(.emptyPassword)
                }
            } else {
                //Checks credentials
                if username == "g"  && password == "g"{
                    ParseCSV().preloadData()
                    self.performSegue(withIdentifier: "main", sender: self) //  segues to main view
                } else{
                    showAlert(.invalidCredentials)
                }
            }
        } else {
            showAlert(.networkFailure)
        }
    }
    
    /**
         Executes the doLogin method.
         - parameters:
             - sender: Login button.
     */
    @IBAction func loginButton(_ sender: AnyObject) {
        doLogin(usernameTextField.text!, password: passwordTextField.text!)
    }
    
    /**
         Calls an alert controller based on the enum provided which will be displayed in the view.
         
         - parameters:
             - alertEnum: Represents the error that should be displayed.
     */
    func showAlert(_ alertEnum: popAlertTypes) {
        let alertController: UIAlertController
        
        switch (alertEnum){
        case .emptyFields:
            alertController = UIAlertController(title: "Error", message:
                "Both fields empty.", preferredStyle: UIAlertControllerStyle.alert)
        case .emptyUsername:
            alertController = UIAlertController(title: "Error", message:
                "Empty username field.", preferredStyle: UIAlertControllerStyle.alert)
        case .emptyPassword:
            alertController = UIAlertController(title: "Error", message:
                "Empty password field.", preferredStyle: UIAlertControllerStyle.alert)
        case .invalidCredentials:
            alertController = UIAlertController(title: "Error", message:
                "Invalid username or password.", preferredStyle: UIAlertControllerStyle.alert)
        case .networkFailure:
            alertController = UIAlertController(title: "No Internet Connection", message:
                "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
        }
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil)) //adding a button the the alert
        self.present(alertController, animated: true, completion: nil) // displays the alert
        alertController.view.tintColor = HouseStyleManager.color.cerise.getColor() // sets button text colour
    }
    
    /// Allows only potrait on any every device expect an iPad
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom != .pad {
            return UIInterfaceOrientationMask.portrait
        } else {
            return UIInterfaceOrientationMask.all
        }
    }
}

extension UINavigationController {
    
    /// Locks rotation
    open override var shouldAutorotate : Bool {
        return true
    }
    
    /// Gets supported orientations
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return (visibleViewController?.supportedInterfaceOrientations)!
    }
}

extension UIAlertController {
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom != .pad {
            return UIInterfaceOrientationMask.portrait
        } else {
            return UIInterfaceOrientationMask.all
        }
    }
    open override var shouldAutorotate : Bool {
        return false
    }
}

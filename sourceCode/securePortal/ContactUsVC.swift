//
//  ContactUsVC.swift
//  securePortal
//
//  Created by Ben Roberts on 21/06/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation
import MessageUI

class ContactUsVC: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(self.presentingViewController != nil){
            //VC is presented modally
            hamburgerBar()
        }
    }
    
    /**
        Enables the use of the hamburgerBar.
        Enables tap-gesture to hide bar.
    */
    func hamburgerBar() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
    }
    
    /**
        Shows an action sheet or a popover depending on if its an iPad or not.
        The action sheet/popover will show a copy button to copy the respective button pressed text.
        The action sheet will show a call/email button which performs the respective actions if supported
         - parameters:
             - sender: phone number and email buttons.
    */
    @IBAction func buttonAction(sender: AnyObject) {
        let buttonTitle = sender.titleLabel!!.text!
    
        let actionAlert = UIAlertController(title: nil, message: buttonTitle, preferredStyle: .ActionSheet)
        // If the button has a '+'
        if buttonTitle[buttonTitle.startIndex.advancedBy(1)] == "+" {
            
            // if it can make a call - iPhone
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                if let call = addCallAction(buttonTitle.substringFromIndex(buttonTitle.startIndex.advancedBy(1))) {
                    actionAlert.addAction(call)
                }
            }
        } else {
            actionAlert.addAction(addEmailAction(buttonTitle))
        }
        
        let copy = UIAlertAction(title:"Copy", style: .Default, handler: { (action: UIAlertAction!) in
            UIPasteboard.generalPasteboard().string = buttonTitle
        })
        let cancel = UIAlertAction(title:"Cancel", style: .Cancel,handler: nil)
        
        
        actionAlert.addAction(copy)
        actionAlert.addAction(cancel)
        actionAlert.popoverPresentationController?.sourceView = sender as! UIButton
        actionAlert.popoverPresentationController?.sourceRect = sender.bounds
        
        self.presentViewController(actionAlert, animated: true, completion: nil)
        actionAlert.view.tintColor = HouseStyleManager.color.Cerise.getColor() // sets button text colour
    }
    
    /**
         Adds the phone action to the actionsheet
         - parameters:
             - phoneNumber: phone number.
     */
    func addCallAction(phoneNumber:String) -> UIAlertAction? {
        let application:UIApplication = UIApplication.sharedApplication()
        
        if let callURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            if application.canOpenURL(callURL) {
                
                return UIAlertAction(title:"Call", style: .Default, handler: { (action: UIAlertAction!) in
                    application.openURL(callURL) })
            }
        }
        return nil
    }
    
    /**
         Action to email within app
         - parameters:
             - emailAddress: email address.
     */
    func addEmailAction(emailAddress:String) -> UIAlertAction {
        let toRecipents = [emailAddress]
        let emailSubject = ""
        let messageBody = ""
        
        return UIAlertAction(title:"Email", style: .Default, handler: { (action: UIAlertAction!) in
                self.displayEmail(emailSubject, messageBody: messageBody, recipents: toRecipents) })
    }
    

    /**
         Displays an email view with the respective email button pressed
         email in the recipient field.
         - parameters:
             - emailSubject: Subject of the email.
             - messageBody: The body of the email.
             - recipents: The recipents of the email.
     */
    func displayEmail(emailSubject:String, messageBody:String, recipents: [String]) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(recipents)
            mail.setSubject(emailSubject)
            mail.setMessageBody(messageBody, isHTML: false)
            mail.navigationBar.tintColor = HouseStyleManager.color.Cerise.getColor()
            presentViewController(mail, animated: true, completion: nil)
        } else {
            print("Cannot send mail")
            popUpAlert()
        }
    }
    
    /// Displays an alert controller for when a email cannot be sent.
    func popUpAlert() {
        let alertController = UIAlertController(title: "Could Not Send Email", message: "Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = HouseStyleManager.color.Cerise.getColor()
    }
    
    /// Generates all the different mail statuses to be displayed.
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        switch result {
        case MFMailComposeResultCancelled:
            print("Mail cancelled")
        case MFMailComposeResultSaved:
            print("Mail saved")
        case MFMailComposeResultSent:
            print("Mail sent")
        case MFMailComposeResultFailed:
            popUpAlert()
            print("Mail sent failure: \(error?.localizedDescription)")
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// Dismisses View Controller
    @IBAction func dismissView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
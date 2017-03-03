//
//  FilterCell.swift
//  securePortal
//
//  Created by Ben Roberts on 20/06/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit

/**
    This enum contains all the filterCellName with their section and row position
    - FromDate: First date of the date range
    - ToDate: Second date of the date range
    - AccountType: The Account types e.g. ECOM
    - CurrencyType: The currency types e.g. GBP
    - PaymentType: The payment types e.g. VISA
    - RequestType: The request type e.g. AUTH
*/
enum filterCellName: Int {
    case fromDateClear = 0, fromDate = 1, toDateClear = 2, toDate = 3, accountType = 4,
         currencyType = 5, paymentType = 6, requestType = 7, errorCode = 8, settledStatus = 9
    
    /// - returns: the section and row number of each cellName.
    func getCell() -> (cellSection:Int, cellRow:Int) {
        switch (self){
        case .fromDate,.fromDateClear:
            return (0,0)
        case .toDate, .toDateClear:
            return (1,0)
        case .accountType:
            return (2,0)
        case .currencyType:
            return (3,0)
        case .paymentType:
            return (4,0)
        case .requestType:
            return (5,0)
        case .errorCode:
            return (6,0)
        case .settledStatus:
            return (7,0)
        }
    }
    
    /// - returns: an array off selection cell parents
    static func getCellSelectionSections() -> [Int] {
        return [ accountType.getCell().cellSection, currencyType.getCell().cellSection, paymentType.getCell().cellSection,
                 requestType.getCell().cellSection, errorCode.getCell().cellSection, settledStatus.getCell().cellSection  ]
    }
}
protocol filterCellDelegate {
    func dateWasSelected(_ dateString:String, cellSection: Int, cellRow: Int)
    func setRow(_ cellSection: Int, cellRow: Int)
    func clearDate(_ cellSection: Int, cellRow: Int)
}

class filterCell: UITableViewCell {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePicker2: UIDatePicker!
    
    let bigFont = UIFont(name: "Avenir-Heavy", size: 17.0)
    let smallFont = UIFont(name: "Avenir-Light", size: 17.0)
    
    let primaryColor = HouseStyleManager.color.cerise.getColor()
    let secondaryColor = UIColor.lightGray
    
    var delegate: filterCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if textLabel != nil {
            textLabel?.font = bigFont
            textLabel?.textColor = primaryColor
        }
        
        if detailTextLabel != nil {
            detailTextLabel?.font = smallFont
            detailTextLabel?.textColor = secondaryColor
        }
        if datePicker != nil {
            datePicker.setValue(UIColor.white, forKey: "textColor")
            datePicker.datePickerMode = .countDownTimer
            datePicker.datePickerMode = .date
        }
        if datePicker2 != nil {
            datePicker2.setValue(UIColor.white, forKey: "textColor")
            datePicker2.datePickerMode = .countDownTimer
            datePicker2.datePickerMode = .date
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /**
        - parameters:
            - sender: All xib button files.
    */
    @IBAction func rowButtons(_ sender: AnyObject) {
        if delegate != nil {
            let buttonAsEnum = filterCellName.init(rawValue: sender.tag)!
            switch buttonAsEnum {
            case .fromDateClear:
                delegate.clearDate(buttonAsEnum.getCell().cellSection, cellRow: buttonAsEnum.getCell().cellRow)
            case .fromDate:
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.short
                
                delegate.dateWasSelected(dateFormatter.string(from: datePicker.date),
                      cellSection: buttonAsEnum.getCell().cellSection, cellRow: buttonAsEnum.getCell().cellRow)
            case .toDateClear:
                delegate.clearDate(buttonAsEnum.getCell().cellSection, cellRow: buttonAsEnum.getCell().cellRow)
            case .toDate:
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.short
                
                delegate.dateWasSelected(dateFormatter.string(from: datePicker2.date),
                   cellSection: buttonAsEnum.getCell().cellSection, cellRow: buttonAsEnum.getCell().cellRow)
            case .accountType,.currencyType, .paymentType, .requestType, .errorCode, .settledStatus:
                delegate.setRow(buttonAsEnum.getCell().cellSection, cellRow: buttonAsEnum.getCell().cellRow)
            }
        }
    }
}

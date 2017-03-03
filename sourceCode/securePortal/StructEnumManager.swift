//
//  structEnumManager.swift
//  securePortal
//
//  Created by Ben Roberts on 05/09/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
import Foundation

class HouseStyleManager {
    enum color {
        
        case white, cerise, ceriseMinus30, ceriseMinus90, ceriseMinus120, darkGreyAdd10, darkGrey, darkGreyMinus10, lightGrey, palePink, black
        
        /// - returns: Colours by enum name.
        func getColor() -> UIColor {
            switch (self){
            case .white:
                return UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            case .cerise:
                return UIColor(red: 231.0/255.0, green: 27.0/255.0, blue: 90.0/255.0, alpha: 1.0)
            case .ceriseMinus30:
                return UIColor(red: 200/255, green: 27/255, blue: 90/255, alpha: 1)
            case .ceriseMinus90:
                return UIColor(red: 140/255, green: 27/255, blue: 90/255, alpha: 1)
            case .ceriseMinus120:
                return UIColor(red: 110/255, green: 27/255, blue: 90/255, alpha: 1)
            case .darkGreyAdd10:
                return UIColor(red: 69.0/255.0, green: 68.0/255.0, blue: 69.0/255.0, alpha: 1.0)
            case .darkGrey:
                return UIColor(red: 57.0/255.0, green: 56.0/255.0, blue: 57.0/255.0, alpha: 1.0)
            case .darkGreyMinus10:
                return UIColor(red: 47.0/255.0, green: 46.0/255.0, blue: 47.0/255.0, alpha: 1.0)
            case .lightGrey:
                return UIColor(red: 228.0/255.0, green: 228.0/255.0, blue: 228.0/255.0, alpha: 1.0)
            case .palePink:
                return UIColor(red: 255.0/255.0, green: 245.0/255.0, blue: 250.0/255.0, alpha: 1.0)
            case .black:
                return UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            }
        }
    }
}


/**
 Groups together the graph bar dates representations.
 
 The date representations:
 - dateString: A string represented as 'fromDate - toDate'
 */
struct  GraphDates {
    let dateFormatter = DateFormatter()
    var dateString: [String]
    
    var dateNS = [(start: Date,end: Date)](){
        didSet {
            var str = [String]()
            for dateRange in dateNS {
                str.append(" \(dateFormatter.string(from: dateRange.start)) - \(dateFormatter.string(from: dateRange.end))")
            }
            dateString = str
        }
    }
    
    init () {
        dateFormatter.dateFormat = "d/M"
        dateString = [String]()
    }
    
    /// Changes dateFormat to hours:minutes
    func isHourFormat(){
        dateFormatter.dateFormat = "HH:mm"
    }
    
    /// Changes dateFormat to day/Month
    func isDayFormat(){
        dateFormatter.dateFormat = "d/M"
    }
    
    /// Changes dateFormat to month/year
    func isYearFormat(){
        dateFormatter.dateFormat = "M/yy"
    }
}


enum RequestType: String {case All = "" , Auth = "AUTH", Refund = "REFUND", Decline = "DECLINE"}
enum SettledStatusTypes: Int {case settled = 100, pending = 0, manual = 1, suspended = 2, cancelled = 3, settling = 10}
enum AccountType: String { case ECOM = "ECOM", CFT = "CFT", CARDSTORE = "CARDSTORE", MOTO = "MOTO", RECUR = "RECUR" }
enum PaymentType: String { case AMEX = "AMEX", MASTERCARD = "MASTERCARD", MASTERCARDDEBIT = "MASTERCARDDEBIT", VISA = "VISA", PAYPAL = "PAYPAL"}
enum timeFrames: String {
    case Total = "Total", Past24Hours = "Past 24 Hours", Past6Days = "Past 6 Days",
    Past12Days = "Past 12 Days", Past30Days = "Past 30 Days", Past60Days = "Past 60 Days"
}
enum CurrencyType: String {
    case EURO = "EUR", GBP = "GBP", USD = "USD"
    func getIndex() -> Int {
        switch self {
        case .GBP:
            return 0
        case .EURO:
            return 1
        case .USD:
            return 2
        }
    }
}

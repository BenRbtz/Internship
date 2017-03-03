//
//  SortCell.swift
//  securePortal
//
//  Created by Ben Roberts on 20/06/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit

class sortCell: UITableViewCell {
    
    let bigFont = UIFont(name: "Avenir-Heavy", size: 17.0)
    let smallFont = UIFont(name: "Avenir-Light", size: 17.0)
    
    let primaryColor = HouseStyleManager.color.cerise.getColor()
    let secondaryColor = UIColor.lightGray
    
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

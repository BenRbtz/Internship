//
//  TransactionCell.swift
//  securePortal
//
//  Created by Ben Roberts on 29/06/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
    @IBOutlet weak var transRefLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountTimeStampLabel: UILabel!
    @IBOutlet weak var accTypeLabel: UILabel!
    @IBOutlet weak var reqTypeLabel: UILabel!
    @IBOutlet weak var settledStatusLabel: UILabel!
    
    override func awakeFromNib() {super.awakeFromNib()}
    override func setSelected(selected: Bool, animated: Bool) { super.setSelected(selected, animated: animated)}

}

//
//  TableViewCell.swift
//  PhnTechnologyTask_22_12_22
//
//  Created by Apple on 23/12/22.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var idLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

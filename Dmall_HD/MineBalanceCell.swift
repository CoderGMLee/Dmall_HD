//
//  MineBalanceCell.swift
//  Dmall_HD
//
//  Created by GM on 17/3/2.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class MineBalanceCell: UITableViewCell {

    @IBOutlet weak var balanceTextLabel: UILabel!

    @IBOutlet weak var scoreTextLabel: UILabel!

    @IBOutlet weak var cardbagTextlabel: UILabel!

    @IBOutlet weak var promotionTextLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

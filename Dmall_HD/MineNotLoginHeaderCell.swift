//
//  MineNotLoginHeaderCell.swift
//  Dmall_HD
//
//  Created by GM on 17/3/2.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class MineNotLoginHeaderCell: UITableViewCell {

    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var loginButton: UIButton!



    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func loginOrRegist(_ sender: UIButton) {
    }
    
}

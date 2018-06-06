//
//  DrawerMenuTableViewSectionHeader.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit

class DrawerMenuTableViewSectionHeader: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var expandCategorySectionButton: UIButton!
    
    @IBOutlet weak var selectCategoryButton: UIButton!
    @IBOutlet weak var customSeparatorHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        customSeparatorHeightConstraint.constant = 0.5
        
    }
}

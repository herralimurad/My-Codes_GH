//
//  DrawerMenuTableCell.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit

class DrawerMenuTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for subView in self.subviews {
            if subView.className.hasSuffix("SeparatorView") {
                subView.hidden = false
            }
        }
    }
}


extension NSObject {
    var className: String {
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }
}

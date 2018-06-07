//
//  ProductCell.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit

/// The ProductCell UITableViewCell subclass
class ProductCell: UITableViewCell {
    /// An array of the product tiles of the cell (1,2 or 3 depending on the layout)
    @IBOutlet var productTiles: [ProductTile]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        layer.opaque = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        layer.shouldRasterize = true
    }
}

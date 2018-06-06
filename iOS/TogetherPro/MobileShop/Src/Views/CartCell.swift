//
//  ProductCheckoutCell.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit
import SnappingStepper
import AlamofireImage

/// The CartCell UITableViewCell subclass, displays a single product and allows quantity modification
class CartCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var discountedPriceLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    @IBOutlet weak var quantityStepper: SnappingStepper!
    /// The cart cell's product, setting the product updates the cell's views
    var product: Product! {
        didSet {
            titleLabel.text = product.title
            quantityStepper.value = Double(product.quantity)
            
            if let discountedPrice = product.discountedPrice {
                let attributes = [NSFontAttributeName: originalPriceLabel.font, NSForegroundColorAttributeName: self.originalPriceLabel.textColor, NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
                let attributedOriginalPrice = NSAttributedString(string: product.price.asCurrencyString, attributes: attributes)
                
                originalPriceLabel.attributedText = attributedOriginalPrice
                discountedPriceLabel.text = discountedPrice.asCurrencyString
            } else {
                originalPriceLabel.text = nil
                discountedPriceLabel.text = product.price.asCurrencyString
            }
            
            productImageView.setImageWithPath(product.photo, cacheIdentifier: "3")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        productImageView.layer.borderWidth = 1.0
        productImageView.layer.borderColor = UIColor.blackColor().CGColor
        productImageView.layer.cornerRadius = 2.0
        quantityStepper.thumbText = nil
        
        quantityStepper.backgroundColor = AppConstants.appTheme.mainColor
    }
}

//
//  ProductTile.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

/// The ProductTile UIControl subclass - displays a single product
class ProductTile: UIControl {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var discountLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var originalPriceLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.masksToBounds = true
        layer.opaque = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        layer.shouldRasterize = true
    }
    /// The product tile unique identifier (used for image caching)
    var identifier: String = ""
    /// The product tile's product (setting the product updates the tile's views)
    var product: Product! {
        didSet {
            titleLabel.text = product.title
            
            if descriptionLabel != nil {
                self.descriptionLabel.text = product.description
            }
            
            if let discount = product.discount {
                discountLabel.text = "\(discount)%↓"
            } else {
                discountLabel.text = nil
            }
            
            if let discountedPrice = product.discountedPrice {
                let attributes = [NSFontAttributeName: originalPriceLabel.font, NSForegroundColorAttributeName: self.originalPriceLabel.textColor, NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
                let attributedOriginalPrice = NSAttributedString(string: product.price.asCurrencyString, attributes: attributes)
                
                originalPriceLabel.attributedText = attributedOriginalPrice
                priceLabel.text = discountedPrice.asCurrencyString
            } else {
                originalPriceLabel.text = " "
                priceLabel.text = product.price.asCurrencyString
            }
            
            imageView.setImageWithPath(product.photo, cacheIdentifier: identifier)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard descriptionLabel != nil else {
            return
        }
        descriptionLabel.hidden = (CGRectGetHeight(descriptionLabel.frame) < descriptionLabel.font.lineHeight)
    }
}

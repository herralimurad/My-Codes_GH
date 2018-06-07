//
//  ProductDetailsCell.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit
import AlamofireImage
import PagedHorizontalView

/// ProductDetailsCell UICollectionViewCell subclass for displaying a single product's information on the ProductDetails screen
class ProductDetailsCell: UICollectionViewCell {
    
    @IBOutlet weak var productImagesPageView: PagedHorizontalView!
    
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var addToCartButtonContainerView: UIView!
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var condtionValueLabel: UILabel!
    @IBOutlet weak var colorValueLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        priceLabel.layer.borderWidth = 3
        priceLabel.layer.borderColor = UIColor.whiteColor().CGColor
        
        addToCartButtonContainerView.layer.shadowColor = UIColor.lightGrayColor().CGColor
        addToCartButtonContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        addToCartButtonContainerView.layer.shadowOpacity = 0.75
        addToCartButtonContainerView.layer.shadowRadius = 2
    }
    /// The cell's product, setting the product updates the cell's views
    var product: Product! {
        didSet {
            titleLabel.text = product.title
            descriptionLabel.text = product.description
            condtionValueLabel.text = product.condition
            colorValueLabel.text = product.color
            
            statusLabel.text = product.status
            viewsLabel.text = "Views : " + product.views
            if (product.district != nil) {
                addressLabel.text = product.city + " ----- > " + product.district
            }
            else {
                addressLabel.text = product.city
            }
            
            
            if let categoryTitle =  product.productCategory?.title {
                categoryLabel.hidden = false
                categoryLabel.text = categoryTitle
            } else {
                 categoryLabel.hidden = true
            }
            
            if let discount = product.discount {
                discountLabel.superview?.hidden = false
                discountLabel.text = "\(discount)%↓"
            } else {
                discountLabel.text = nil
                discountLabel.superview?.hidden = true
            }
            
            if let discountedPrice = product.discountedPrice {
                let originalPriceAttributes = [NSForegroundColorAttributeName: priceLabel.textColor, NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
                let discountedPriceAttributes = [NSFontAttributeName: priceLabel.font, NSForegroundColorAttributeName: UIColor.whiteColor()]
                
                let plainPriceString = (discountedPrice.asCurrencyString + "\n" + product.price.asCurrencyString) as NSString
                
                let attributedPrice = NSMutableAttributedString(string: plainPriceString as String, attributes: discountedPriceAttributes)
                
                attributedPrice.addAttributes(originalPriceAttributes, range:plainPriceString.rangeOfString(product.price.asCurrencyString))
                
                priceLabel.attributedText = attributedPrice
            } else {
                priceLabel.text = product.price.asCurrencyString
            }
            
            
            productImagesPageView.collectionView.reloadData()
            productImagesPageView.moveToPage(0, animated: false)
            
            addToCartButtonContainerView.hidden = Catalog.sharedCatalog.cart.products.contains(product)
        }
    }
}

extension ProductDetailsCell: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(ProductImageCollectionViewCell), forIndexPath: indexPath) as! ProductImageCollectionViewCell
        
        let photo = product.photos[indexPath.row]
        
        if !photo.networkResource {
            if let productPhoto = Image(named: photo) {
                
                cell.imageView.image = productPhoto
            }
        } else {
            if let url = NSURL(string: photo) {
                
                cell.imageView.af_setImageWithURL(url)
            }
        }
        
        return cell
    }
}

extension ProductDetailsCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        changeButtonAlphaForScrollViewOffset(scrollView.contentOffset.y)
    }
    
    func changeButtonAlphaForScrollViewOffset(offset: CGFloat) {
        
        let maximumVerticalOffset = contentScrollView.contentSize.height - CGRectGetHeight(contentScrollView.bounds)
        let currentVerticalOffset = contentScrollView.contentOffset.y
        
        let percentageVerticalOffset = currentVerticalOffset / maximumVerticalOffset
        
        var newAlpha: CGFloat = 1
        if maximumVerticalOffset > 50 && offset > 0 {
            newAlpha -= log(percentageVerticalOffset*10)
        }
    
        addToCartButtonContainerView.alpha = newAlpha
    }
}

extension ProductDetailsCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentScrollView.setContentOffset(CGPointZero, animated: false)
        addToCartButtonContainerView.transform = CGAffineTransformIdentity
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        priceLabel.layer.cornerRadius = ceil(CGRectGetWidth(self.priceLabel.frame)/2)
        
        addToCartButton.layer.cornerRadius = ceil(CGRectGetWidth(addToCartButton.frame)/2)
        
        addToCartButtonContainerView.layer.shadowPath = UIBezierPath(roundedRect: addToCartButtonContainerView.bounds, cornerRadius: addToCartButton.layer.cornerRadius).CGPath
    }
}

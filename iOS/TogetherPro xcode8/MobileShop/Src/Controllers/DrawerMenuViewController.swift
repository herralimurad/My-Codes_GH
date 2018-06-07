//
//  DrawerViewController.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit
import KYDrawerController

class DrawerMenuViewController: UIViewController {
    let mainCategoryCellIdentifier = "MainCategoryCell"
    let subCategoryCellIdentifier = "SubCategoryCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var catalogInfoDetailView: UIView!
    
    @IBOutlet weak var menuLogo: UIImageView!
    @IBOutlet weak var catalogNameLabel: UILabel!
    @IBOutlet weak var mailAddressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var facebookLabel: UILabel!
    @IBOutlet weak var skypeLabel: UILabel!
    
    @IBOutlet weak var catalogInfoHeightConstraint: NSLayoutConstraint!
    
    var expandedCategories: Set<Int> = Set()
    
    var arrMenu = ["Settings", "About App"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
//        catalogNameLabel.text = AppConstants.catalogName
//        mailAddressLabel.text = AppConstants.mailAddress
//        phoneNumberLabel.text = "Phone: " + AppConstants.phoneNumber
//        skypeLabel.text       = "Skype: " + AppConstants.skype
//        facebookLabel.text    = "Facebook: " + AppConstants.facebook
        
        catalogNameLabel.text = NSUserDefaults.standardUserDefaults().stringForKey("username")
        mailAddressLabel.text = NSUserDefaults.standardUserDefaults().stringForKey("email")
        phoneNumberLabel.text = "Phone: " + NSUserDefaults.standardUserDefaults().stringForKey("telephone")!
        skypeLabel.text       = "WhatsApp: " + NSUserDefaults.standardUserDefaults().stringForKey("telephone")!
        facebookLabel.text    = "Facebook: " + NSUserDefaults.standardUserDefaults().stringForKey("fb_link")!
        
        menuLogo.setImageWithPath(NSUserDefaults.standardUserDefaults().stringForKey("ios_icon_url")!, cacheIdentifier: "")
        
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            arrMenu = [appSettings["action_settings"] as! String, appSettings["aboutapp"] as! String]
            
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DrawerMenuViewController.loadList(_:)),name:"load", object: nil)
    }
    
    func loadList(notification: NSNotification){
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            arrMenu = [appSettings["action_settings"] as! String, appSettings["aboutapp"] as! String]
            
        }
        tableView.reloadData()
    }
}

extension DrawerMenuViewController {
    @IBAction func expandButtonTapped(sender: UIButton) {
        
        sender.enabled = false
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
            if sender.selected {
                self.catalogInfoHeightConstraint.constant /= 2.0
                self.catalogInfoDetailView.alpha = 0.0
                sender.transform = CGAffineTransformIdentity
            } else {
                self.catalogInfoHeightConstraint.constant *= 2.0
                self.catalogInfoDetailView.alpha = 1.0
                sender.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            }
            
            self.view.layoutIfNeeded()
            
            }) { (finished) in
                if finished {
                    sender.enabled = true
                    sender.selected = !sender.selected
                }
        }
    }
}

extension DrawerMenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let mainCategoriesCount = Catalog.sharedCatalog.mainCategories.count
        let menuCount = 1
        
        return mainCategoriesCount + menuCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if expandedCategories.contains(section) {
            if let subCategories = Catalog.sharedCatalog.categories[section] {
               return subCategories.count + 1
            }
            
            return 0
        }
        else if section < Catalog.sharedCatalog.mainCategories.count {
            return 1
        }
        else {
            return arrMenu.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section < Catalog.sharedCatalog.mainCategories.count {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(mainCategoryCellIdentifier) as! DrawerMenuTableViewSectionHeader
                
                cell.titleLabel.text = Catalog.sharedCatalog.mainCategories[indexPath.section].title
                cell.expandCategorySectionButton.tag = indexPath.section
                cell.selectCategoryButton.tag = indexPath.section
                
                let shouldExpandSection = expandedCategories.contains(indexPath.section)
                
                cell.expandCategorySectionButton.selected = shouldExpandSection
                
                if shouldExpandSection {
                    cell.expandCategorySectionButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                } else {
                    cell.expandCategorySectionButton.transform = CGAffineTransformIdentity
                }
                
                return cell
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(subCategoryCellIdentifier) as! DrawerMenuTableCell
            
            if let subCategorires = Catalog.sharedCatalog.categories[indexPath.section] {
                cell.titleLabel.text = subCategorires[indexPath.row - 1].title
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(subCategoryCellIdentifier) as! DrawerMenuTableCell
            cell.titleLabel.text = arrMenu[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60
        }
        
        return 45
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        guard indexPath.section < Catalog.sharedCatalog.categories.count else {
            if let drawerController = navigationController?.parentViewController as? KYDrawerController {
                let mainNavVC = drawerController.mainViewController as! UINavigationController
                let mainVC = mainNavVC.viewControllers.first as! MainInterfaceViewController
                let menuViewType = arrMenu[indexPath.row]
                mainVC.menuViewType = menuViewType
                
                drawerController.setDrawerState(.Closed, animated: true)
            }
            return
        }
        
        if let subcategories = Catalog.sharedCatalog.categories[indexPath.section] {
            // First row is the main category cell, substract 1 to match the subcategories count
            let subCategoryIndex = indexPath.row - 1
            
            if subCategoryIndex < subcategories.count {
                let subCategory = subcategories[subCategoryIndex]
                
                self.didSelectCategoy(subCategory)
            }
        }
    }
}

extension DrawerMenuViewController {
    @IBAction func mainCategorySectionButtonTapped(sender: UIButton) {
        
        didSelectCategoy(Catalog.sharedCatalog.mainCategories[sender.tag])
    }
    
    func didSelectCategoy(category: Category) {
        if let drawerController = navigationController?.parentViewController as? KYDrawerController {
            let mainNavVC = drawerController.mainViewController as! UINavigationController
            let mainVC = mainNavVC.viewControllers.first as! MainInterfaceViewController
            let productCatalog = Catalog.sharedCatalog.productCatalogForCategory(category)
            mainVC.productCatalog = productCatalog
            mainVC.title = category.title
            
            drawerController.setDrawerState(.Closed, animated: true)
        }
    }
}

extension DrawerMenuViewController {
    @IBAction func expandCategorySectionButtonTapped(sender: UIButton) {
        
        sender.enabled = false
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
            if sender.selected {
                sender.transform = CGAffineTransformIdentity
                self.tableView.collapseSection(sender.tag) {
                    self.expandedCategories.remove(sender.tag)
                }
            } else {
                sender.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                self.expandedCategories.insert(sender.tag)
                self.tableView.expandSection(sender.tag)
            }
            
            self.view.layoutIfNeeded()
            
            }) { (finished) in
                if finished {
                    sender.enabled = true
                    sender.selected = !sender.selected
                }
        }
    }
}

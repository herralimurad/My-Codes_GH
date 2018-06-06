//
//  SearchResultsViewController.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit

class SearchResultsViewController: UITableViewController, UISearchResultsUpdating {
    // MARK: Types
    
    struct TableViewConstants {
        static let tableViewCellIdentifier = "searchResultsCell"
    }
    
    // MARK: Properties

    var mainInterfaceVC: MainInterfaceViewController!
    lazy var visibleResults: [Product] = []

    /// A `nil` / < 3 characters filter string means show no results. Otherwise, show only results containing the filter.
    var filterString: String? = nil {
        didSet {
            if filterString == nil || filterString!.characters.count < 3 {
                visibleResults = []
                self.view.hidden = true
            }
            else {
                self.view.hidden = false
                // Filter the results based on the filter string.
                visibleResults = Catalog.sharedCatalog.products.filter { $0.title.lowercaseString.containsString(filterString!.lowercaseString) }
            }

            tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(TableViewConstants.tableViewCellIdentifier, forIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel!.text = visibleResults[indexPath.row].title
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        mainInterfaceVC.performSegueWithIdentifier(MainIntefaceViewControllerConstants.showProductDetailsSegueIdentifier, sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        /*
        `updateSearchResultsForSearchController(_:)` is called when the controller is
        being dismissed to allow those who are using the controller they are search
        as the results controller a chance to reset their state. No need to update
        anything if we're being dismissed.
        */
        guard searchController.active else {
            return
        }
        
        filterString = searchController.searchBar.text
    }
}

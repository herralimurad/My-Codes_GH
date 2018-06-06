//
//  LoadingViewController.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit
import DTIToastCenter

class LoadingViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoadingViewController.loadXML), name: UIApplicationDidBecomeActiveNotification, object: nil)
        loadXML()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func showAlertControllerWithMessage(message: String) {
        var buttonTitle = "Dismiss"
        
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            buttonTitle = appSettings["dismiss"] as! String
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        let dismissAction = UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Cancel) { (action) in
            // Dismiss button tapped, do nothing
        }
        
        buttonTitle = "Retry"
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            buttonTitle = appSettings["retry"] as! String
        }
        
        let retryAction = UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Default) { (action) in
            self.presentedViewController?.dismissViewControllerAnimated(true, completion:  nil)
            self.loadXML()
        }
        
        alertController.addAction(dismissAction)
        alertController.addAction(retryAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func loadXML() {
        if !activityIndicator.isAnimating() {
            
            var statusLabelTitle = "Loading, please wait..."
            
            if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
                statusLabelTitle = appSettings["loading"] as! String
            }
            
            activityIndicator.startAnimating()
            statusLabel.text = statusLabelTitle
            
            Catalog.sharedCatalog.loadXML(AppConstants.XMLRemoteResourcePath) { error in
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    
                    if error != nil {
                        
                        var errorMessage = error!.localizedDescription
                        
                        if let errorReason = error!.localizedFailureReason {
                            errorMessage = errorReason
                        }
                        
                        self.showAlertControllerWithMessage(errorMessage)
                        self.statusLabel.text = errorMessage
                        
                    } else {
                        self.activityIndicator.stopAnimating()
                        self.performSegueWithIdentifier("MainStroyboardSegue", sender: nil)
                    }
                }
            }
        }
    }
}

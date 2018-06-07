//
//  AppDelegate.swift
//  Mobile Shop
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit
import DTIToastCenter
import IQKeyboardManagerSwift
import AlamofireImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        DTIToastCenter.defaultCenter.registerCenter()
        IQKeyboardManager.sharedManager().enable = true
        
        /*******************************************************************************
        * Enter YOUR OneSignal appId for push notifications in AppConstants.           *
        * Refer to https://onesignal.com and https://onesignal.com/provisionator       *
        * for generating certificates and keys.                                        *
        ********************************************************************************/
        // https://onesignal.com
        // https://onesignal.com/provisionator
        
        if !AppConstants.OneSignalAppId.isEmpty {
            let _ = OneSignal(launchOptions: launchOptions, appId: AppConstants.OneSignalAppId, handleNotification: nil)
            
            OneSignal.defaultClient().enableInAppAlertNotification(true)
        }
        
        AppConstants.applyCurrentTheme()
        
        return true
    }
}


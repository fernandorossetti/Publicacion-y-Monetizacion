//
//  AppDelegate.swift
//  NextURacing
//
//  Created by Alejocram on 24/05/16.
//  Copyright © 2016 NextU. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AdColonyDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Flurry.setLogLevel(FlurryLogLevelAll)
        Flurry.startSession("B5BSW2YW3HZRXJJFZN7T")
        
        AdColony.configureWithAppID("app0798a799c9f04e12ba", zoneIDs: ["vz5b43de9e320e493181"], delegate: self, logging: true)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func onAdColonyAdAvailabilityChange(available: Bool, inZone zoneID: String) {
        if available {
            NSNotificationCenter.defaultCenter().postNotificationName("zoneReady", object: nil)
        } else {
             NSNotificationCenter.defaultCenter().postNotificationName("zoneLoading", object: nil)
        }
    }
    
    func onAdColonyV4VCReward(success: Bool, currencyName: String, currencyAmount amount: Int32, inZone zoneID: String) {
        NSNotificationCenter.defaultCenter().postNotificationName("setReward", object: Int(amount))
    }


}


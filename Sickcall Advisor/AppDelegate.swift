//
//  AppDelegate.swift
//  Sickcall Advisor
//
//  Created by Dominic Smith on 10/31/17.
//  Copyright © 2017 Sickcall LLC. All rights reserved.
//

import UIKit
import UserNotifications
import Parse
import FacebookCore
import FacebookLogin
import ParseFacebookUtilsV4
import Stripe
import ParseLiveQuery

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //change color of time/status jaunts to white
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: uicolorFromHex(0x006a52)], for:UIControlState())
        
        UITabBar.appearance().tintColor = uicolorFromHex(0x006a52)
        
        let navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.barTintColor = uicolorFromHex(0xffffff)
        navigationBarAppearace.tintColor = uicolorFromHex(0x006a52)
        
        //Stripe ***
        STPPaymentConfiguration.shared().publishableKey = "pk_test_oP3znUobvO9fTRuYb6Qo7PYB"
        //STPPaymentConfiguration.shared().publishableKey = "pk_live_chGMzaqKctIYqbalvJbvRzWz"
        
        //Parse *****
        
        // Override point for customization after application launch.
        // Parse.enableLocalDatastore()
        
        // Initialize Parse.
        
        //MARK - this is the real one below
        let configuration = ParseClientConfiguration {
            $0.applicationId = "O9M9IE9aXxHHaKmA21FpQ1SR26EdP2rf4obYxzBF"
            $0.clientKey = "LdoCUneRAIK9sJLFFhBFwz2YkW02wChG5yi2wkk2"
            $0.server = "https://celecare.herokuapp.com/parse"
            // $0.server = "http://192.168.1.75:5000/parse"
        }
        Parse.initialize(with: configuration)
        
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        if PFUser.current()?.objectId != nil{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "main")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()

            //not signed in
        } else {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "welcome")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let installation = PFInstallation.current()
        //replace badge # when someone clicks on notification
        installation?.badge = 0
        installation?.saveInBackground()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("deviceToken \(deviceToken)")
        // Store the deviceToken in the current Installation and save it to Parse
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        //replace badge # when someone clicks on notification
        installation?.badge = 0
        installation?.saveInBackground()
    }
    
   /* func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        //parse stuff
        PFPush.handle(userInfo)
    }*/
    
    //@available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        PFPush.handle(notification.request.content.userInfo)
        completionHandler([.alert, .sound])
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    //define custom color jaunts..  see https://coderwall.com/p/dyqrfa/customize-navigation-bar-appearance-with-swift for reference
    func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}

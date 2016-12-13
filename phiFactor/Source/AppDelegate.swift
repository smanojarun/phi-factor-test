//
//  AppDelegate.swift
//  PhiFactor
//
//  Created by Apple on 18/05/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import UIKit
import AWSS3
import Fabric
import Crashlytics
import UserNotifications

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, ABPadLockScreenViewControllerDelegate {

    var window: UIWindow?
    let gaiInstance = GAI.sharedInstance()
    var inactiveDelegate: AppInactiveDelegate?

    var remoteNotifyUUID = ""
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        /*
         Store the completion handler.
         */
        AWSS3TransferUtility.interceptApplication(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.sharedApplication().idleTimerDisabled = true
        UIApplication.sharedApplication().statusBarHidden = true
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
//        logIntoFile()
        print("AppDelegate didFinishLaunchingWithOptions begin")
        self.loadModelFile()
//        if !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
//            if #available(iOS 10.0, *){
//                UNUserNotificationCenter.currentNotificationCenter().delegate = self
//                UNUserNotificationCenter.currentNotificationCenter().requestAuthorizationWithOptions([.Badge, .Sound, .Alert], completionHandler: {(granted, error) in
//                    if (granted)
//                    {
//                        UIApplication.sharedApplication().registerForRemoteNotifications()
//                    }
//                    else{
//                        //Do stuff if unsuccessful...
//                    }
//                })
//            }
//            else { //If user is not on iOS 10 use the old methods we've been using
//                let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
//                application.registerUserNotificationSettings(notificationSettings)
//            }
//        }
        if !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
            let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
        }
        Fabric.with([Crashlytics.self])
        Crashlytics.sharedInstance().setUserIdentifier(UIDevice.currentDevice().identifierForVendor?.UUIDString)
        
        // Configure tracker from GoogleService-Info.plist.
//        var configureError:NSError?
//        GGLContext.sharedInstance().configureWithError(&configureError)
//        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        
        gaiInstance.trackerWithTrackingId(googleTrackingID)
        gaiInstance.dispatchInterval = 0
        gaiInstance.trackUncaughtExceptions = true  // report uncaught exceptions
//        gaiInstance.logger.logLevel = GAILogLevel.Verbose  // remove before app release
        
        PFGlobalConstants.environment(.Local)
        
        print("AppDelegate didFinishLaunchingWithOptions end")
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
    
    func loadModelFile() {
        let instanceOfCustomObject: CVResult = CVResult()
        let errorCode = instanceOfCustomObject.loadModelFile()
        print(errorCode)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)
        NSUserDefaults.standardUserDefaults().setObject(tokenString, forKey: "deviceToken")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
         print(userInfo)
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        if let notificationDic : NSDictionary = userInfo as NSDictionary
        {
            if var uuidFromServer = notificationDic.objectForKey("uuid") as? String {
                uuidFromServer = uuidFromServer.stringByReplacingOccurrencesOfString("Some", withString: "").stringByReplacingOccurrencesOfString("(", withString: "").stringByReplacingOccurrencesOfString(")", withString: "")
                print(uuidFromServer)
                remoteNotifyUUID = uuidFromServer
                PFGlobalConstants.authenticateUserByTouchID({ (status) in
                    switch (status)
                    {
                    case .authorized:
                        PFGlobalConstants.authenticateUserForwebLogin(self.remoteNotifyUUID)
                        break
                    case .unAuthorized:
                        dispatch_async(dispatch_get_main_queue()) {
                            if(PFGlobalConstants.isPasscodeAvailable()) {
                                let lockScreen = ABPadLockScreenViewController(delegate: self, complexPin: false)
                                lockScreen.setAllowedAttempts(3)
                                lockScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                                lockScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                                isAuthorizationRequesting = true;
                                UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(lockScreen, animated: true, completion: nil)
                            }
                            else
                            {
                                UIAlertView(title: "", message: "No registered passcode found.", delegate: nil, cancelButtonTitle: "Ok").show()
                            }
                        }
                        break
                    case .unKnown:
                        dispatch_async(dispatch_get_main_queue()) {
                            let alert = UIAlertView(title: "", message: "Check touch id configured and enabled on your device to begin.", delegate: nil, cancelButtonTitle: "Ok")
                            alert.show()
                        }
                        break
                    case .canceled:
                        break
                    }
                })
            }
        }
    }
    
    func logIntoFile() {
        print("AppDelegate logIntoFile begin")
        var paths: Array = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory: String = paths[0]
        let logPath: String = documentsDirectory.stringByAppendingString("/console.log")
        if !NSFileManager.defaultManager().fileExistsAtPath(logPath)
        {
            let tempStr = ""
            do {
                try tempStr.writeToFile(logPath, atomically: true, encoding: NSUTF8StringEncoding)
                print("Write success")
            }
            catch
            {
                print("Write Failed")
            }
        }
        else {
            if let data = NSData(contentsOfFile: logPath)
            {
                if ((data.length/1024)/1024) >= 50
                {
                    do {
                        try NSFileManager.defaultManager().removeItemAtPath(logPath)
                    }
                    catch let err as NSError
                    {
                        print(err)
                    }
                }
            }
        }
        
//        let allPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        let documentsDirectory = allPaths.first!
//        let pathForLog = documentsDirectory.stringByAppendingString("/yourFile.txt")
        
        freopen(logPath.cStringUsingEncoding(NSASCIIStringEncoding)!, "a+", stderr)
        freopen(logPath.cStringUsingEncoding(NSASCIIStringEncoding)!, "a+", stdin)
        freopen(logPath.cStringUsingEncoding(NSASCIIStringEncoding)!, "a+", stdout)
        
//        if (isatty(STDERR_FILENO) == 0)
//        {
//            freopen(logPath, "a+", stderr)
//            freopen(logPath, "a+", stdin)
//            freopen(logPath, "a+", stdout)
//        }
        print(logPath)
        print("AppDelegate logIntoFile end")
    }
    
//    //MARK: Lock Screen Setup Delegate
//    func pinSet(pin: String!, padLockScreenSetupViewController padLockScreenViewController: ABPadLockScreenSetupViewController!) {
//        thePin = pin
//        NSUserDefaults.standardUserDefaults().setObject(pin, forKey: "PF_Passcode")
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func unlockWasCancelledForSetupViewController(padLockScreenViewController: ABPadLockScreenAbstractViewController!) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
    //MARK: Lock Screen Delegate
    func padLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!, validatePin pin: String!) -> Bool {
        print("Validating Pin \(pin)")
        let passcode = PFPassCode.stringByReplacingOccurrencesOfString("X", withString: user)
        let thePin = NSUserDefaults.standardUserDefaults().stringForKey(passcode)
        return thePin == pin
    }
    
    func unlockWasSuccessfulForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Successful!")
        PFGlobalConstants.authenticateUserForwebLogin(self.remoteNotifyUUID)
        isAuthorizationRequesting = false;
        UIApplication.sharedApplication().keyWindow?.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func unlockWasUnsuccessful(falsePin: String!, afterAttemptNumber attemptNumber: Int, padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Failed Attempt \(attemptNumber) with incorrect pin \(falsePin)")
        if attemptNumber == 3 {
            isAuthorizationRequesting = false;
            UIApplication.sharedApplication().keyWindow?.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func unlockWasCancelledForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Cancled")
        isAuthorizationRequesting = false;
        UIApplication.sharedApplication().keyWindow?.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
}

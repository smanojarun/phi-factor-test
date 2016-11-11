//
//  PFGlobalConstants.swift
//  PhiFactor
//
//  Created by Apple on 29/06/16.
//  Copyright © 2016 Hubino. All rights reserved.
//

import Foundation
import DeviceKit
import AVFoundation
import Alamofire
import LocalAuthentication

var itemtobeplayed: NSURL!
var videoStatus1: String!
var videoStatus2: String!
var videoStatus3: String!
var videoStatus4: String!
var baseURL: NSString = "https://dev-api.phifactor.com"
var amazomURL = "https://s3-us-west-2.amazonaws.com/dev-phifactor"
var S3BucketName = "dev-phifactor"

let introVideoInstruction = "The sky is blue."
let facialVideoInstruction = "Capture face from left to right."
let headVideoInstruction = "Capture from top to bottom."
let eyeVideoInstruction = "Capture Eye from left to right"
let battryAlertText = "Battery level below 40%. Please connect the charger."
let documentUploadingAlertText = "Document upload in progress."
let videoUploadingAlertText = "Recording process has completed, upload videos inprogress."
let networkErrorAlertText = "Network not available. Please check your internet connections."
let noValuesAlert = "Content may expired or not assigned yet. Contact admin for more details."
let faqURL = "https://phifactor.com/7f29385ba747553b17043dd57841cbc761099136/faq.html"
let APP_DELEGATE = UIApplication.sharedApplication().delegate as? AppDelegate
var canShowBatteryAlert = true

let googleTrackingID = "UA-81645332-1"
let PFCameraviewcontrollerScreenName = "PFCameraviewcontrollerscreen"
let PFWebViewScreenName = "PFWebView"
let PFUploadstatusViewControllerScreenName = "PFUploadstatusViewController"
let PFSinginViewControllerScreenName = "PFSinginViewController"
let PhiFactorIntroScreenName = "PhiFactorIntro"
let VideoPreviewViewScreenName = "PFVideoPreviewView"
//let PF_USERNAME = "pfUserName"
//let PF_PASSWORD = "pfPassword"
let PF_QUALITYCHECK = "isQualityCheckOn"
let PF_PatientIDOnDB = "pfPatientIDOnDB"
let PF_ResumeVideoCount = "pfResumeVideoCount"
let PF_MinimumTimeLimit = 60.0
let PF_MaximumTimeLimit = 300.0
var isAuthorizationRequesting = false;

enum authenticateStatus {
    case authorized
    case unAuthorized
    case canceled
    case unKnown
}
enum appEnvironment {
    case Production
    case Staging
    case Development
    case Local
}
class PFGlobalConstants: NSObject {

    let device = Device()

    func isDeviceCompatibile() -> Bool {
        print(device)
        if (device == .iPhone6sPlus)||(device == .iPhoneSE) || (device == .iPhone6s) {
            return true
        } else {
            return true
        }
    }

    /**
     Removing the observer and calling the web service for update status for that video.
     - parameter notification: notification object which gives the specified URL
     */
    func videoStatus(videoUrl: NSURL, iteration: NSString) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if iteration == "1" {
            videoStatus1 = "completed"
            defaults.setObject(videoStatus1, forKey: "completedVideoStatus1")
            completed_video_update_status(videoStatus1,url: videoUrl.absoluteString)

        }
        else if iteration == "2" {
            videoStatus2 = "completed"
            defaults.setObject(videoStatus2, forKey: "completedVideoStatus2")
            completed_video_update_status(videoStatus2,url: videoUrl.absoluteString)

        }
        else if iteration == "3" {
            videoStatus3 = "completed"
            defaults.setObject(videoStatus3, forKey: "completedVideoStatus3")
            completed_video_update_status(videoStatus3,url: videoUrl.absoluteString)

        }
        else if iteration == "4" {
            videoStatus4 = "completed"
            defaults.setObject(videoStatus4, forKey: "completedVideoStatus4")
            completed_video_update_status(videoStatus4,url: videoUrl.absoluteString)

        }
    }

    /**
     Calling the webservice for updating the video upload status
     - parameter videoStatus1: status String to be updated.
     - parameter url:         status updated for the coresponding video on that URL
     */

    func completed_video_update_status(videoStatus1: String!,url: AnyObject!)  {
        let defaults = NSUserDefaults.standardUserDefaults()
        var access_token: String!
        var token_type: String!
        let cameraModel = PFCameraScreenModel()
        access_token = defaults.stringForKey("access_token")
        token_type = defaults.stringForKey("token_type")
        requestString = "\(baseURL)/update_media_status?Authorization=\(token_type)&access_token=\(access_token)"
        url1 = NSURL(string: requestString as String)!
        urlRequest = NSMutableURLRequest(URL: url1)
        urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        cameraModel.update_media_status(videoStatus1,url: url)
        Alamofire.request(urlRequest)
            .responseJSON { response in
                switch response.result {
                case .Failure( let error):
                    print(error)
                case .Success(let responseObject):
                    print(responseObject)
                }
        }
    }
    
    class func authenticateUserByTouchID(complition :(status: authenticateStatus) ->()) {
        if !isAuthorizationRequesting
        {
            let context = LAContext()
            
            // Declare a NSError variable.
            var error: NSError?
            
            // Set the reason string that will appear on the authentication alert.
            var reasonString = "Authentication is needed to access your data."
            
            // Check if the device can evaluate the policy.
            if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
                isAuthorizationRequesting = true;
                [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                    
                    if success {
                        isAuthorizationRequesting = false;
                        complition(status: .authorized)
                    }
                    else{
                        // If authentication failed then show a message to the console with a short description.
                        // In case that the error is a user fallback, then show the password alert view.
                        print(evalPolicyError?.localizedDescription)
                        
                        switch evalPolicyError!.code {
                            
                        case LAError.SystemCancel.rawValue:
                            print("Authentication was cancelled by the system")
                            isAuthorizationRequesting = false;
                            complition(status: .unAuthorized)
                            
                        case LAError.UserCancel.rawValue:
                            print("Authentication was cancelled by the user")
                            isAuthorizationRequesting = false;
                            complition(status: .canceled)
                            
                        case LAError.UserFallback.rawValue:
                            print("User selected to enter custom password")
                            isAuthorizationRequesting = false;
                            complition(status: .unAuthorized)

                        default:
                            print("Authentication failed")
                            isAuthorizationRequesting = false;
                            complition(status: .unAuthorized)
                        }
                    }
                    
                })]
            }
            else
            {
                isAuthorizationRequesting = false;
                complition(status: .unKnown)
            }
        }
    }
    
    
    class func authenticateUserForwebLogin(uuidFromServer : String) {
        let registerDeviceUrlString = "\(baseURL)/touch_id_success"
        let registerDeviceURl = NSURL(string: registerDeviceUrlString)
        urlRequest = NSMutableURLRequest(URL: registerDeviceURl!)
        urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let loginModel = PFLogingModel()
        urlRequest = loginModel.getPushLoginParams(uuidFromServer)
        Alamofire.request(urlRequest).responseJSON { (response) in
            switch response.result
            {
            case .Failure(let error):
                let err = error as NSError
                if err.code == -1009 {
//                    self.netwrkAlertLabel.text = networkErrorAlertText
//                    self.networkAlertViewAction()
                }
                else {
//                    self.netwrkAlertLabel.text = "There is an error occured."
//                    self.networkAlertViewAction()
                }
                break
            case .Success(let responseObject):
                let httpStatusCode = response.response?.statusCode
                print(httpStatusCode)
                
                if(httpStatusCode==200) {
                    let response = responseObject as! NSDictionary
                    let result = response.objectForKey("result")! as! String
                    let message = response.objectForKey("message")! as! String
//                    let alert = UIAlertView(title: "", message: message, delegate: nil, cancelButtonTitle: "Ok")
//                    alert.show()
                }
                else if httpStatusCode == 201 {
                    let response = responseObject as! NSDictionary
                    let message = response.objectForKey("message")! as! String
//                    let alert = UIAlertView(title: "", message: message, delegate: nil, cancelButtonTitle: "Ok")
//                    alert.show()
                }
                break
            }
        }
        
    }
    
    class func sendEventWithCatogory(catagory: String, action: String, label: String, value: NSNumber?)
    {
        let dic = GAIDictionaryBuilder.createEventWithCategory(catagory, action: action, label: label, value: value).build()
        APP_DELEGATE?.gaiInstance.defaultTracker.send(dic as [NSObject:AnyObject])
        APP_DELEGATE?.gaiInstance.dispatch()
    }
    class func sendException(description: String, isFatal: Bool)
    {
        let dic = GAIDictionaryBuilder.createExceptionWithDescription(description, withFatal: NSNumber(bool: isFatal)).build()
        APP_DELEGATE?.gaiInstance.defaultTracker.send(dic as [NSObject:AnyObject])
        APP_DELEGATE?.gaiInstance.dispatch()
    }

    class func setResumeVideoCount(count: Int) {
        NSUserDefaults.standardUserDefaults().setInteger(count, forKey: PF_ResumeVideoCount)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    class func removeResumeVideoCount() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(PF_ResumeVideoCount)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    class func logoutUser()
    {
        print("PFGlobalConstants logoutUser start")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PhiFactorIntro") as! PhiFactorIntro
        nextViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        let nav = UINavigationController(rootViewController: nextViewController)
        nav.navigationBarHidden = true
        
        dispatch_async(dispatch_get_main_queue()) { 
            UIView.transitionWithView((APP_DELEGATE?.window)!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                APP_DELEGATE!.window?.backgroundColor = UIColor.blackColor()
                APP_DELEGATE!.window?.rootViewController = nav
                
            }) { (isCompleted) in
                print("PFGlobalConstants logoutUser end")
            }
        }
        
    }
    class func isPasscodeAvailable() ->Bool
    {
        return NSUserDefaults.standardUserDefaults().stringForKey("PF_Passcode") != nil ? true : false
    }
    class func environment(environment: appEnvironment) {
        switch environment {
        case .Production:
            baseURL = "https://api.phifactor.com"
            amazomURL = "https://s3-us-west-2.amazonaws.com/portal.phifactor.com"
            S3BucketName = "portal.phifactor.com"
            break
        case .Staging:
            baseURL = "https://staging-api.phifactor.com"
            amazomURL = "https://s3-us-west-2.amazonaws.com/staging-phifactor"
            S3BucketName = "staging-phifactor"
            break
        case .Development:
            baseURL = "https://dev-api.phifactor.com"
            amazomURL = "https://s3-us-west-2.amazonaws.com/dev-phifactor"
            S3BucketName = "dev-phifactor"
            break
        case .Local:
            baseURL = "http://10.10.1.6:9001"
            amazomURL = "https://s3-us-west-2.amazonaws.com/dev-phifactor"
            S3BucketName = "dev-phifactor"
            break
        }
    }
    class func getS3BucketName() -> String {
        
        return S3BucketName
    }
    class func deviceRemainingFreeSpaceInBytes() -> Int64? {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if let systemAttributes = try? NSFileManager.defaultManager().attributesOfFileSystemForPath(documentDirectoryPath.last!) {
            if let freeSize = systemAttributes[NSFileSystemFreeSize] as? NSNumber {
//              let strValue = NSByteCountFormatter.stringFromByteCount(freeSize.longLongValue, countStyle: NSByteCountFormatterCountStyle.File)
//                let bsfj = NSNumber.aws_numberFromString(strValue)
//                let dfbnjk = Int(strValue)
                return freeSize.longLongValue
            }
        }
        // something failed
        return nil
    }

}
extension Double {
    var degreesToRadians: Double { return self * M_PI / 90 }
    var radiansToDegrees: Double { return self * 90 / M_PI }
}

// Usage: insert view.pushTransition right before changing content
extension UIView {
    
    func pushTransition(duration: CFTimeInterval) {
        let animation: CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromTop
        animation.duration = duration
        self.layer.addAnimation(animation, forKey: kCATransitionPush)
    }
}

extension CMSampleBuffer {
    /**
     Converting the sampleBuffer to UIImage.
     - parameter sampleBuffer: given sampleBuffer to be converted.
     - returns: converted UIImage from given sample Buffer is valid. Otherwise returns nil.
     */
    
    func toUIImage() -> UIImage {
        // Get a CMSampleBuffer's Core Video image buffer for the media data
        let imageBuffer = CMSampleBufferGetImageBuffer(self)
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        // Get the number of bytes per row for the pixel buffer
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!)
        // Get the number of bytes per row for the pixel buffer
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
        // Get the pixel buffer width and height
        let width = CVPixelBufferGetWidth(imageBuffer!)
        let height = CVPixelBufferGetHeight(imageBuffer!)
        // Create a device-dependent RGB color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // Create a bitmap graphics context with the sample buffer data
        let context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, CGImageAlphaInfo.PremultipliedFirst.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue)
        // Create a Quartz image from the pixel data in the bitmap graphics context
        let quartzImage = CGBitmapContextCreateImage(context!)
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        // Create an image object from the Quartz image
        let image = UIImage(CGImage: quartzImage!)
        return image
    }
    
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController where top.view.window != nil {
                return topViewController(top)
            } else if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        
        return base
    }
}

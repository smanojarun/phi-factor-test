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

var itemtobeplayed: NSURL!
var videoStatus1: String!
var videoStatus2: String!
var videoStatus3: String!
var videoStatus4: String!
let baseURL: NSString = "https://dev-api.phifactor.com"
//let baseURL: NSString = "https://api.phifactor.com"
//let baseURL: NSString = "https://staging-api.phifactor.com"
let introVideoInstruction = "The sky is blue."
let facialVideoInstruction = "Capture face from left to right."
let headVideoInstruction = "Capture from top to bottom."
let eyeVideoInstruction = "Capture Eye from left to right"
let battryAlertText = "Battery level below 40%. Please connect the charger."
let documentUploadingAlertText = "Document upload in progress."
let faqURL = "https://phifactor.com/7f29385ba747553b17043dd57841cbc761099136/faq.html"

var canShowBatteryAlert = true

class PFGlobalConstants: NSObject {

    let device = Device()

    func isDeviceCompatibile() -> Bool {
        print(device)
        if (device == .iPhone6sPlus)||(device == .iPhoneSE) || (device == .iPhone6s) {
            return true
        } else {
            return false
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
        CVPixelBufferLockBaseAddress(imageBuffer!, 0)
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
        let quartzImage = CGBitmapContextCreateImage(context)
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer!, 0)
        // Create an image object from the Quartz image
        let image = UIImage(CGImage: quartzImage!)
        return image
    }
    
}
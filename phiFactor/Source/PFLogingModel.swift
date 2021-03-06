//
//  PFLogingModel.swift
//  PhiFactor
//
//  Created by Hubino-Air13 on 5/20/16.
//  Copyright © 2016 Hubino-Air13. All rights reserved.
//

import UIKit
var user: String!
var pass: String!
var urlRequest: NSMutableURLRequest!
var url1: NSURL!
var requestString: NSString!
var urlReuestRefresh: NSString!

/// Manipulating the user login objects and API parameters.
class PFLogingModel: NSObject {

    /**
     Genrating the NSMutableURLRequest with the requested parameters.
     
     - parameter user:      username or email
     - parameter pass:      password
     - parameter grandType: password or refresh token
     - parameter url:       base URL
     
     - returns: returns request with the provided parameters
     */
    
    func param (user:NSString,pass: NSString, grandType: NSString, url: NSMutableURLRequest
        ) -> NSMutableURLRequest {
        print("PFLogingModel param begin")
        let app_version : Int = Int(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String)!
        let parameters1 = [
                           "username": user,
                           "password": pass,
                           "client_id": "102216378240-rf6fjt3konig2fr3p1376gq4jrooqcdm",
                           "client_secret": "bYQU1LQAjaSQ1BH9j3zr7woO",
                           "grant_type": grandType,
                           "app_version":app_version
                           ]
    do {
        print(parameters1)
    urlRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject (parameters1,options: NSJSONWritingOptions())
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    } catch {
    print("JSON serialization Error!")
    }
        print("PFLogingModel param end")
    return urlRequest
    }
    
    /**
     Genrating the NSMutableURLRequest for resetPassword with the requested parameters.
     
     - parameter old:  current password of the user
     - parameter new:  new password to be changed
     - parameter uuid: UUID of the device requesting password change.
     
     - returns: returns request with the provided parameters
     */
    
    func resetPasswordParam(old:NSString,new:NSString,uuid:NSString) ->NSMutableURLRequest{
        print("PFLogingModel resetPasswordParam begin")
        let parameters1 = ["old_password": old, "new_password": new, "uuid":uuid]
        do {
            urlRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters1,options: NSJSONWritingOptions())
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("JSON serialization Error!")
        }
        print("PFLogingModel resetPasswordParam end")
        return urlRequest
    }
    
    func getRegisterDeviceParams(emailId : String, canClearSession: Bool) -> NSMutableURLRequest {
        let accessToken : String = NSUserDefaults.standardUserDefaults().objectForKey("deviceToken") as! String
        print("PFLogingModel getRegisterDeviceParams begin")
        let deviceId : String = (UIDevice.currentDevice().identifierForVendor?.UUIDString)!
        var clear = "0"
        if canClearSession {
            clear = "1"
        }
        
        let parameters1 = [
                            "email_id": emailId,
                            "access_token": accessToken,
                            "device_id": deviceId,
                            "clear": clear,
                            ]
        print(parameters1)
        do {
            urlRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters1,options: NSJSONWritingOptions())
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("JSON serialization Error!")
        }
        print("PFLogingModel getRegisterDeviceParams end")
        return urlRequest
    }
    
    func getPushLoginParams(uuidFromserver : String) -> NSMutableURLRequest {
        print("PFLogingModel getPushLoginParams begin")
        let parameters1 = [
            "push_status": "YES",
            "uuid": uuidFromserver
        ]
        do {
            urlRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters1,options: NSJSONWritingOptions())
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("JSON serialization Error!")
        }
        print("PFLogingModel getPushLoginParams end")
        return urlRequest
    }

}

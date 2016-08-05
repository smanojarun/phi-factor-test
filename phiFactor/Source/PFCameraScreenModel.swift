//
//  PFCameraScreenModel.swift
//  PhiFactor
//
//  Created by Apple on 20/05/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

var patientIdArray = NSMutableArray()
var defaultsarr = NSMutableArray()
var videoDefaultsArr = NSMutableArray()
var patarr = NSMutableArray()
var itemtoplayedarr = NSMutableArray()
var localUrlarr = NSMutableArray()
var oldVideoUrlArr = NSMutableArray()
var videoArray = NSMutableArray()

/// Manipulating and background processing of camera screen features.
class PFCameraScreenModel: NSObject {

    var instanceOfCustomObject: AWSBackgroundupload = AWSBackgroundupload()
    var videoData: NSData!
    var patientId: String!
    var dateFormatter: String!
    var name: NSString="bg"
    let S3BucketName: String = "phifactor"
    let S3UploadKeyName: String = "uploadfileswift.txt"
    var defaults = NSUserDefaults.standardUserDefaults()
    
    var avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    /**
     Uploading the video to specified URL.
     
     - parameter iteratio: Iteration of the video.
     */
    func nextvideo(iteratio: String) {
        print("PFCameraScreenModel nextvideo \(iteratio) begin")
        videoData = NSData(contentsOfURL: itemtobeplayed)
        patientId = defaults.stringForKey("patient_id")
        let date = NSDate()
        let formatter = NSDateFormatter()
        var awsURLOne: NSString?
        var awsURLTwo: NSString?
        var awsURLThree: NSString?
        var awsURLFour: NSString?
        formatter.dateFormat = "yyyyMMddHHmmss"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter = formatter.stringFromDate(date)

        if(iteratio=="1") {
            awsURLOne = NSString .localizedStringWithFormat("https://s3-us-west-2.amazonaws.com/dev-phifactor/%@/%@/%@_%@_%@.MOV", patientId!, dateFormatter, patientId!, dateFormatter, iteratio)
            videoArray.addObject(awsURLOne!)
            let tempUrl = "\(itemtobeplayed),\(patientId),\(iteratio)"
            localUrlarr.addObject(tempUrl)
            print(localUrlarr)
            print(videoArray)
            if (defaults.objectForKey("patient") != nil) {
                defaultsarr = defaults.objectForKey("patient") as! NSMutableArray
                patientIdArray.removeAllObjects()
                for obj in defaultsarr {
                    let patientDefultValue = obj
                    print(patientDefultValue)
                    patientIdArray.addObject(patientDefultValue)
                }
                print(patientIdArray)

            }

            patientIdArray.addObject(patientId)
            print(patientIdArray)
            defaults.setObject (patientIdArray, forKey: "patient")

            defaults.setObject (awsURLOne, forKey: "awsURLOne")
        }
        else if(iteratio=="2") {
            
            awsURLTwo = NSString .localizedStringWithFormat("https://s3-us-west-2.amazonaws.com/dev-phifactor/%@/%@/%@_%@_%@.MOV", patientId!, dateFormatter, patientId!, dateFormatter, iteratio)
            videoArray.addObject(awsURLTwo!)
            let tempUrl = "\(itemtobeplayed),\(patientId),\(iteratio)"
            localUrlarr.addObject(tempUrl)
            defaults.setObject (awsURLTwo, forKey: "awsURLTwo")
        }
        else if(iteratio=="3") {
            awsURLThree = NSString .localizedStringWithFormat("https://s3-us-west-2.amazonaws.com/dev-phifactor/%@/%@/%@_%@_%@.MOV", patientId!, dateFormatter, patientId!, dateFormatter, iteratio)
            videoArray.addObject(awsURLThree!)
            let tempUrl = "\(itemtobeplayed),\(patientId),\(iteratio)"
            localUrlarr.addObject(tempUrl)

            defaults.setObject (awsURLThree, forKey: "awsURLThree")

        }
        else if(iteratio=="4") {
            awsURLFour = NSString .localizedStringWithFormat("https://s3-us-west-2.amazonaws.com/dev-phifactor/%@/%@/%@_%@_%@.MOV", patientId!, dateFormatter, patientId!, dateFormatter, iteratio)
            videoArray.addObject(awsURLFour!)
            let tempUrl = "\(itemtobeplayed),\(patientId),\(iteratio)"
            localUrlarr.addObject(tempUrl)

            defaults.setObject (awsURLFour, forKey: "awsURLFour")

        }
        for obj in localUrlarr {
            let temp = obj
            itemtoplayedarr.addObject(temp)
        }
        localUrlarr.removeAllObjects()
        defaults.setObject (itemtoplayedarr, forKey: "item")
        defaults.setObject (videoArray, forKey: "videoArray")
        defaults.setObject (dateFormatter, forKey: "dateFormatter")
        defaults.setObject (iteratio, forKey: "iteration")
        if    let onOrOFF = defaults.objectForKey("onDemanswitch") as? Bool {
            print(onOrOFF)
            if(onOrOFF) {
                return
            }
            else {
                instanceOfCustomObject .uploadData(videoData, patientId, iteratio, itemtobeplayed, dateFormatter)
            }
        }
        else {
            instanceOfCustomObject .uploadData(videoData, patientId, iteratio, itemtobeplayed, dateFormatter)
        }
        print("PFCameraScreenModel nextvideo \(iteratio) end")
    }
    
    func update_media_status(videoStatus1: String!, url: AnyObject!) -> NSMutableURLRequest{
        print("PFCameraScreenModel update_media_status \(url) begin")
        let parameters1 = ["video_url": url, "video_status": videoStatus1 ]
        print(parameters1)
        do {
            let json = try NSJSONSerialization.dataWithJSONObject(parameters1, options: NSJSONWritingOptions())
            print(json)
            urlRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters1, options: NSJSONWritingOptions())
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("JSON serialization Error!")
        }
        print("PFCameraScreenModel update_media_status \(url) end")
        return urlRequest

    }
    
    /**
     Uploading the patient details to server at the end of the 4th video recording complition
     */
    
    func registerPatient() {
        print("PFCameraScreenModel registerPatient begin")
        let defaults = NSUserDefaults.standardUserDefaults()
        var access_token: String!
        var token_type: String!
        access_token = defaults.stringForKey("access_token")
        token_type = defaults.stringForKey("token_type")
        requestString = "\(baseURL)/add_patient_info?Authorization=\(token_type)&access_token=\(access_token)"
        url1 = NSURL(string: requestString as String)!
        urlRequest = NSMutableURLRequest(URL: url1)
        urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let Gclinical_id: NSNumber!
        let GPt_id: String!
        let GPt_age: NSNumber!
        let GPt_name: String!
        let Ggender_id: NSNumber!
        let GEthinicity_id: NSNumber!
        let Glanguage_id: NSNumber!
        let GPt_encounterID: String!
        Gclinical_id = defaults.integerForKey("clinical_id")
        GPt_name = defaults.stringForKey("patient_name")
        GPt_id = defaults.stringForKey("patient_id")
        GPt_age = defaults.integerForKey("patient_age")
        Ggender_id = defaults.integerForKey("gender_id")
        GEthinicity_id = defaults.integerForKey("ethen_id")
        Glanguage_id = defaults.integerForKey("lan_id")
        GPt_encounterID = defaults.stringForKey("encounterID")
        let patientModel : PFPatientDetailsModel = PFPatientDetailsModel()
        patientModel.param(Gclinical_id,patient_name: GPt_name,patient_id: GPt_id,age_id: GPt_age,gender_id: Ggender_id,ethinicity_id: GEthinicity_id,language_id: Glanguage_id, encounterID: GPt_encounterID)
        Alamofire.request(urlRequest)
            .responseJSON { response in
                // do whatever you want here
                switch response.result {
                case .Failure( let error):
                    let httpStatusCode = response.response?.statusCode
                    print(httpStatusCode)
                    if(httpStatusCode==401) {
                        print("Invalid access token")
                        let refresh_token = defaults.stringForKey("refresh_token")! as String
                        requestString = "\(baseURL)/login"
                        print(requestString)
                        let client_id = "102216378240-rf6fjt3konig2fr3p1376gq4jrooqcdm"
                        let client_secret = "bYQU1LQAjaSQ1BH9j3zr7woO"
                        url1 = NSURL(string: requestString as String)!
                        urlRequest = NSMutableURLRequest(URL: url1)
                        urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
                        patientModel.loadvaluesParam(client_id, client_secret: client_secret, refresh_token: refresh_token, grant_type: "refresh_token")
                        Alamofire.request(urlRequest)
                            .responseJSON { response in
                                switch response.result {
                                case .Failure( let error):
                                    print(error)
                                case .Success(let responseObject):
                                    print(responseObject)
                                    let response = responseObject as! NSDictionary
                                    let access_token = response.objectForKey("access_token")! as! String
                                    let token_type = response.objectForKey("token_type")! as! String
                                    let refresh_token = response.objectForKey("refresh_token")! as! String
                                    let defaults = NSUserDefaults.standardUserDefaults()
                                    defaults.setObject (access_token ,forKey: "access_token")
                                    defaults.setObject(token_type,forKey: "token_type")
                                    defaults.setObject(refresh_token,forKey: "refresh_token")
                                    self.registerPatient()
                                }
                        }
                    }
                    print(error)
                case .Success(let responseObject):
                    print(responseObject)
                    defaults.removeObjectForKey("clinical_id")
                    defaults.removeObjectForKey("patient_name")
                    defaults.removeObjectForKey("patient_id")
                    defaults.removeObjectForKey("patient_age")
                    defaults.removeObjectForKey("gender_id")
                    defaults.removeObjectForKey("ethen_id")
                    defaults.removeObjectForKey("lan_id")
                    defaults.removeObjectForKey("encounterID")
                }
                print("PFCameraScreenModel registerPatient end")
        }
    }

    /**
     Uploading the document to specified URL.
     
     - parameter imageFilePath: Document URL in local device.
     */
    func uploadDocument(imageFilePath: String) {
        print("PFCameraScreenModel uploadDocument begin")
        let imageData = NSData(contentsOfFile: imageFilePath)
        patientId = defaults.stringForKey("patient_id")
        let date = NSDate()
        let formatter = NSDateFormatter()
    
        formatter.dateFormat = "yyyyMMddHHmmss"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter = formatter.stringFromDate(date)
        let doc = NSString .localizedStringWithFormat("https://s3-us-west-2.amazonaws.com/dev-phifactor/%@/%@/%@_%@_Document.jpg", patientId!, dateFormatter, patientId!, dateFormatter)
        defaults.setObject (patientIdArray, forKey: "patient")
        
        defaults.setObject (doc, forKey: "doc")
        
        instanceOfCustomObject .uploadData(imageData, patientId, dateFormatter, NSURL(string: imageFilePath))
        print("PFCameraScreenModel uploadDocument end")
    }
}

//    func awsUrl(dateFormatter: String,iteration: String,patient: String) -> String  {
//        let awsURLOne = NSString .localizedStringWithFormat("https: //s3-us-west-2.amazonaws.com/dev-phifactor/%@/%@/%@_%@_%@.MOV", patient,dateFormatter,patient,dateFormatter,iteration)
//    return awsURLOne as String
//    }
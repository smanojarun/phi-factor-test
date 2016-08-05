//
//  PFUploadStatusModel.swift
//  PhiFactor
//
//  Created by Apple on 05/07/16.
//  Copyright © 2016 Hubino. All rights reserved.
//

import UIKit

var uploadSuccessfullyArr = NSMutableArray()
var mediaStatusArr = NSMutableArray()
var inprogressArr = NSMutableArray()

/// Manipulating the response from and to the server of Upload status details.
class PFUploadStatusModel: NSObject {

    var defaults = NSUserDefaults.standardUserDefaults()
    var videoURL: String!
    var videoId: String!
    var iteration: String!
    var dateFormatter: String!
    var instanceOfCustomObject: AWSBackgroundupload = AWSBackgroundupload()

    /**
     Itreating the response From getPatientVideoStatus and loading into the table
     */
    class func getpatientVideoStatusResponse(patientDetailsArray: NSArray)  {
        for i in (0..<patientDetailsArray.count).reverse(){
            
            let patientIndex =  patientDetailsArray.objectAtIndex(i)
            let patient_idValue =  (patientIndex.objectForKey("patient_mrn_id")) as! String
            let patientIndexValue =  patientIndex.objectForKey("patient_media") as! NSArray
            let introMediaStatus = patientIndexValue.objectAtIndex(0).objectForKey("media_status") as! String
            let facialMediaStatus = patientIndexValue.objectAtIndex(1).objectForKey("media_status") as! String
            let headMediaStatus = patientIndexValue.objectAtIndex(2).objectForKey("media_status") as! String
            let eyeDetectMediaStatus = patientIndexValue.objectAtIndex(3).objectForKey("media_status") as! String

            if(introMediaStatus=="completed") {
                let patientUploadIntro = "PF\(patient_idValue)-Introduction Video"
                uploadSuccessfullyArr.addObject(patientUploadIntro)
            }
            else {
                let patientUploadIntro = "PF\(patient_idValue)-Introduction Video"
                inprogressArr.addObject(patientUploadIntro)
            }
            if(facialMediaStatus=="completed") {
                let patientUploadFacial = "PF\(patient_idValue)-Facial Feature Analysis Video"
                uploadSuccessfullyArr.addObject(patientUploadFacial)
            }
            else {
                let patientUploadFacial = "PF\(patient_idValue)-Facial Feature Analysis Video"
                inprogressArr.addObject(patientUploadFacial)
            }
            
            if(headMediaStatus=="completed") {
                let patientUploadHeadMedia = "PF\(patient_idValue)-Head Feature Analysis Video"
                uploadSuccessfullyArr.addObject(patientUploadHeadMedia)
            }
            else {
                let patientUploadHeadMedia = "PF\(patient_idValue)-Head Feature Analysis Video"
                inprogressArr.addObject(patientUploadHeadMedia)
            }
            if(eyeDetectMediaStatus=="completed") {
                let patientUploadEyeDetectMediaStatus = "PF\(patient_idValue)-Eye Feature Analysis Video"
                uploadSuccessfullyArr.addObject(patientUploadEyeDetectMediaStatus)
            }
            else {
                let patientUploadEyeDetectMediaStatus = "PF\(patient_idValue)-Eye Feature Analysis Video"
                inprogressArr.addObject(patientUploadEyeDetectMediaStatus)
            }
        }
    }

    func uploadAllFiles() {
        videoArray = defaults.objectForKey("videoArray") as! NSMutableArray
        print(videoArray)
        itemtoplayedarr = defaults.objectForKey("item") as! NSMutableArray
        for obj in itemtoplayedarr {
            let str = obj
            print(str)
            let delimiter = ","
            var token = str.componentsSeparatedByString(delimiter)
            print(token)
            videoURL = token[0]
            videoId = token[1]
            iteration = token[2]
            print(videoURL)
            print(videoId)
            let video = NSURL(string: videoURL as String)
            print(video)
            let videoDataValue = NSData(contentsOfURL: video!)
            for obj in videoArray {
                print(videoArray)
                let str = obj
                print(str)
                let delimiter = "/"
                var token = str.componentsSeparatedByString(delimiter)
                let patientId = token[4]
                let iterationInVideo = token[6]
                let delimiter1 = "_"
                var token1 = iterationInVideo.componentsSeparatedByString(delimiter1)
                let iterationCount = token1[2]
                let videoURL = NSURL(string: str as! String)
                if(videoId == patientId && iterationCount.containsString(iteration)) {
                    let date = NSDate()
                    let formatter = NSDateFormatter()
                    formatter.dateFormat = "yyyyMMddHHmmss"
                    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
                    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                    dateFormatter = formatter.stringFromDate(date)
                    print(dateFormatter)
                    instanceOfCustomObject .uploadData(videoDataValue, patientId, iteration, videoURL, dateFormatter)
                }
            }
        }
    }

    func singleUpload(patient_Id: String)  {
        print(patient_Id)
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter = formatter.stringFromDate(date)

        videoArray = defaults.objectForKey("videoArray") as! NSMutableArray
        print(videoArray)
        itemtoplayedarr = defaults.objectForKey("item") as! NSMutableArray
        for obj in itemtoplayedarr {
            let str = obj
            print(str)
            let delimiter = ","
            var token = str.componentsSeparatedByString(delimiter)
            print(token)
            videoURL = token[0]
            videoId = token[1]
            iteration = token[2]
            print(videoURL)
            print(videoId)
            let video = NSURL(string: videoURL as String)
            let videoDataValue  = NSData(contentsOfURL: video!)
            for obj in videoArray {
                let str = obj
                print(str)
                let delimiter = "/"
                var token = str.componentsSeparatedByString(delimiter)
                let patientId = token[4]
                print(patientId)
                if(patient_Id == patientId) {
                    let date = NSDate()
                    let formatter = NSDateFormatter()
                    formatter.dateFormat = "yyyyMMddHHmmss"
                    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
                    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                    dateFormatter = formatter.stringFromDate(date)
                    let videoURL = NSURL(string: str as! String)
                    instanceOfCustomObject .uploadData(videoDataValue, patientId, iteration, videoURL, dateFormatter)
                }
            }
        }
    }

}

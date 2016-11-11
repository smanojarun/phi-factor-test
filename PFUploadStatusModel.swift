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
var completedArr = NSMutableArray()
var inprogressArr = NSMutableArray()
var notAvailableArr = NSMutableArray()
var introMediaDate:String!
var facialMediaDate:String!
var headMediaDate:String!
var eyeDetectMediaDate:String!


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
        uploadSuccessfullyArr.removeAllObjects()
        completedArr.removeAllObjects()
        for i in (0..<patientDetailsArray.count).reverse(){
            
            let patientIndex =  patientDetailsArray.objectAtIndex(i)
            let patient_idValue =  (patientIndex.objectForKey("patient_mrn_id")) as! String
            let patientIndexValue =  patientIndex.objectForKey("patient_media") as! NSArray
            
            var introMediaStatus = "N/A"
            var facialMediaStatus = "N/A"
            var headMediaStatus = "N/A"
            var eyeDetectMediaStatus = "N/A"
                        for item in patientIndexValue {
                print(item)
                
                
            }
            
            switch patientIndexValue.count {
            case 1:
                introMediaStatus = (patientIndexValue.objectAtIndex(0).objectForKey("media_status") as? String)!
                if let introDate = patientIndexValue.objectAtIndex(0).objectForKey("inserted_date") as? String {
                    introMediaDate = introDate
                }
                break
            case 2:
                introMediaStatus = (patientIndexValue.objectAtIndex(0).objectForKey("media_status") as? String)!
                facialMediaStatus = (patientIndexValue.objectAtIndex(1).objectForKey("media_status") as? String)!
                if let introDate = patientIndexValue.objectAtIndex(0).objectForKey("inserted_date") as? String {
                    introMediaDate = introDate
                }
                if let facialDate = patientIndexValue.objectAtIndex(1).objectForKey("inserted_date") as? String {
                    facialMediaDate = facialDate
                }
                break
            case 3:
                introMediaStatus = (patientIndexValue.objectAtIndex(0).objectForKey("media_status") as? String)!
                facialMediaStatus = (patientIndexValue.objectAtIndex(1).objectForKey("media_status") as? String)!
                headMediaStatus = (patientIndexValue.objectAtIndex(2).objectForKey("media_status") as? String)!
                if let introDate = patientIndexValue.objectAtIndex(0).objectForKey("inserted_date") as? String {
                    introMediaDate = introDate
                }
                if let facialDate = patientIndexValue.objectAtIndex(1).objectForKey("inserted_date") as? String {
                    facialMediaDate = facialDate
                }
                if let headDate = patientIndexValue.objectAtIndex(2).objectForKey("inserted_date") as? String {
                    headMediaDate = headDate
                }
                break
            case 4:
                introMediaStatus = (patientIndexValue.objectAtIndex(0).objectForKey("media_status") as? String)!
                facialMediaStatus = (patientIndexValue.objectAtIndex(1).objectForKey("media_status") as? String)!
                headMediaStatus = (patientIndexValue.objectAtIndex(2).objectForKey("media_status") as? String)!
                eyeDetectMediaStatus = (patientIndexValue.objectAtIndex(3).objectForKey("media_status") as? String)!
                if let introDate = patientIndexValue.objectAtIndex(0).objectForKey("inserted_date") as? String {
                    introMediaDate = introDate
                }
                if let facialDate = patientIndexValue.objectAtIndex(1).objectForKey("inserted_date") as? String {
                    facialMediaDate = facialDate
                }
                if let headDate = patientIndexValue.objectAtIndex(2).objectForKey("inserted_date") as? String {
                    headMediaDate = headDate
                }
                if let eyeDate = patientIndexValue.objectAtIndex(3).objectForKey("inserted_date") as? String {
                    eyeDetectMediaDate = eyeDate
                }
                break
            default:
                break
            }
            
            
            if(introMediaStatus=="completed") {
                let patientUploadIntro = "PF\(patient_idValue)\("|")\(introMediaDate)\("|")\(introMediaStatus)|Introduction Video"
                uploadSuccessfullyArr.addObject(patientUploadIntro)
                completedArr.addObject(patientUploadIntro)
            }
            if(introMediaStatus=="inprogress")
 {
                let patientUploadIntro = "PF\(patient_idValue)\("|")\(introMediaDate)\("|")\(introMediaStatus)|Introduction Video"
                uploadSuccessfullyArr.addObject(patientUploadIntro)
                inprogressArr.addObject(patientUploadIntro)
            }
            if(introMediaStatus=="N/A") {
                let patientUploadIntro = "PF\(patient_idValue)\("|")\(introMediaDate)\("|")\(introMediaStatus)|Introduction Video"
                uploadSuccessfullyArr.addObject(patientUploadIntro)
                notAvailableArr.addObject(patientUploadIntro)
            }

            if(facialMediaStatus=="completed") {
                let patientUploadFacial = "PF\(patient_idValue)\("|")\(facialMediaDate)\("|")\(facialMediaStatus)|Facial Feature"

                //let patientUploadFacial = "PF\(patient_idValue)-Facial Feature Analysis Video"
                uploadSuccessfullyArr.addObject(patientUploadFacial)
                completedArr.addObject(patientUploadFacial)
            }
            if(facialMediaStatus=="inprogress")
            {
                let patientUploadFacial = "PF\(patient_idValue)\("|")\(facialMediaDate)\("|")\(facialMediaStatus)|Facial Feature"
                uploadSuccessfullyArr.addObject(patientUploadFacial)
                inprogressArr.addObject(patientUploadFacial)
            }
            if(facialMediaStatus=="N/A")
            {
                let patientUploadFacial = "PF\(patient_idValue)\("|")\(facialMediaDate)\("|")\(facialMediaStatus)|Facial Feature"
                uploadSuccessfullyArr.addObject(patientUploadFacial)
                notAvailableArr.addObject(patientUploadFacial)
            }

            
            if(headMediaStatus=="completed") {
                let patientUploadHeadMedia = "PF\(patient_idValue)\("|")\(headMediaDate)\("|")\(headMediaStatus)|Head Feature"

                //let patientUploadHeadMedia = "PF\(patient_idValue)-Head Feature Analysis Video"
                uploadSuccessfullyArr.addObject(patientUploadHeadMedia)
                completedArr.addObject(patientUploadHeadMedia)
            }
            
            if(headMediaStatus=="N/A") {
                let patientUploadHeadMedia = "PF\(patient_idValue)\("|")\(headMediaDate)\("|")\(headMediaStatus)|Head Feature"
                uploadSuccessfullyArr.addObject(patientUploadHeadMedia)
                notAvailableArr.addObject(patientUploadHeadMedia)
            }
if(eyeDetectMediaStatus=="completed") {
                let patientUploadEyeDetectMediaStatus = "PF\(patient_idValue)\("|")\(eyeDetectMediaDate)\("|")\(eyeDetectMediaStatus)|Eye Feature"

//                let patientUploadEyeDetectMediaStatus = "PF\(patient_idValue)-Eye Feature Analysis Video"
                uploadSuccessfullyArr.addObject(patientUploadEyeDetectMediaStatus)
                completedArr.addObject(patientUploadEyeDetectMediaStatus)
            }
            if(eyeDetectMediaStatus=="inprogress") {
                let patientUploadEyeDetectMediaStatus = "PF\(patient_idValue)\("|")\(eyeDetectMediaDate)\("|")\(eyeDetectMediaStatus)|Eye Feature"
                uploadSuccessfullyArr.addObject(patientUploadEyeDetectMediaStatus)
                inprogressArr.addObject(patientUploadEyeDetectMediaStatus)
            }
            if(eyeDetectMediaStatus=="N/A") {
                let patientUploadEyeDetectMediaStatus = "PF\(patient_idValue)\("|")\(eyeDetectMediaDate)\("|")\(eyeDetectMediaStatus)|Eye Feature"
                uploadSuccessfullyArr.addObject(patientUploadEyeDetectMediaStatus)
                notAvailableArr.addObject(patientUploadEyeDetectMediaStatus)
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
//                    instanceOfCustomObject .uploadData(videoDataValue, patientId, iteration, videoURL, dateFormatter)
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
//                    instanceOfCustomObject .uploadData(videoDataValue, patientId, iteration, videoURL, dateFormatter)
                }
            }
        }
    }

}

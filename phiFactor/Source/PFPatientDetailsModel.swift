//
//  PFPatientDetailsModel.swift
//  PhiFactor
//
//  Created by Hubino-Air13 on 5/20/16.
//  Copyright © 2016 Hubino-Air13. All rights reserved.
//

import UIKit

var languageDict: NSDictionary!
var Gender_dict: NSDictionary!
var ethincity: NSDictionary!
var clinical_trial: NSDictionary!
var gender_id: NSNumber!
var clinical_id: NSNumber!
var Ethinicity_id: NSNumber!
var language_id: NSNumber!
var languages_id_arr = NSMutableArray()
var languages_name_arr = NSMutableArray()
var gender_id_arr = NSMutableArray()
var gender_name_arr = NSMutableArray ()
var ethincity_id_arr = NSMutableArray()
var ethincity_name_arr = NSMutableArray ()
var clinical_trials_id_arr = NSMutableArray()
var clinical_trials_name_arr = NSMutableArray ()
var cliical_trains_novalue = NSMutableArray()

/// Manipulating the Patient details objects and API parameters.
class PFPatientDetailsModel: NSObject {

    /**
     Iterating the dictionary and getting the prefered details added to array.
     - parameter response: dictionary to be iterated.
     - returns: iterated values from dictionary.
     */
    
    func getResonse(response: NSDictionary) ->  NSMutableArray {
        let languages = response.objectForKey("language")! as! NSArray
        let gendervalues = response.objectForKey("gender")! as! NSArray
        let ethincityValues=response.objectForKey("ethnicity")! as! NSArray
        let clinical_trial_values = response.objectForKey("clinical_trial")! as! NSArray
        
        print(languages)
        print(gendervalues)
        print(ethincityValues)
        print(clinical_trial_values)
        
        for dict in gendervalues {
            gender_id_arr.addObject( dict.objectForKey("gender_id")!)
            gender_name_arr.addObject(dict.objectForKey("gender_name")!)
            
            print(gender_id_arr)
            print(gender_name_arr)
            
        }
        
        for dict in languages {
            languages_id_arr.addObject( dict.objectForKey("language_id")!)
            languages_name_arr.addObject(dict.objectForKey("language_name")!)
            
            print(languages_id_arr)
            print(languages_name_arr)
            
            
        }
        
        for dict in ethincityValues {
            ethincity_id_arr.addObject( dict.objectForKey("ethnicity_id")!)
            ethincity_name_arr.addObject(dict.objectForKey("ethnicity_name")!)
            
            print(ethincity_id_arr)
            print(ethincity_name_arr)
            
        }
        
        for dict in clinical_trial_values {
            clinical_trials_id_arr.addObject( dict.objectForKey("ct_id")!)
            clinical_trials_name_arr.addObject(dict.objectForKey("ct_name")!)
            
            print(clinical_trials_id_arr)
            print(clinical_trials_name_arr)
            
        }
        
        return clinical_trials_id_arr
    }

    /**
     Genrating mutable request for accesstoken
     - parameter client_id:     prefered client id
     - parameter client_secret: prefered client secret id
     - parameter refresh_token: refresh_token which already got while login
     - parameter grant_type:    refresh token

     - returns: returns request with the provided parameters
     */
    
    func loadvaluesParam(client_id: String,client_secret: String,refresh_token: String,grant_type: String) -> NSMutableURLRequest {
        print("PFPatientDetailsModel loadvaluesParam begin")
        let app_version : Int = Int(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String)!
        let parameter = [
            
            "client_id":  client_id,
            "client_secret":  client_secret,
            "refresh_token":  refresh_token,
            "grant_type":  grant_type,
            "app_version": app_version
        ]
        do {
            let json = try NSJSONSerialization.dataWithJSONObject(parameter, options: NSJSONWritingOptions())
            print(json)
            urlRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameter, options: NSJSONWritingOptions())
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("JSON serialization Error!")
        }
        print("PFPatientDetailsModel loadvaluesParam end")
        return urlRequest
    }

    /**
     Genrating the NSMutableURLRequest with the requested parameters.

     - parameter clinical_trial_id: chossen by user
     - parameter patient_name:      patient name
     - parameter patient_id:        patient_id
     - parameter age_id:            patient Age
     - parameter gender_id:         patient gender
     - parameter ethinicity_id:     ethinicity_id choosen by user
     - parameter language_id:       language_id choosen by user

     - returns: returns request with the provided parameters
     */

    func param(clinical_trial_id: NSNumber, patient_name: NSString,patient_id: NSString, age_id: NSNumber, gender_id: NSNumber, ethinicity_id: NSNumber, language_id: NSNumber, encounterID: NSString) -> NSMutableURLRequest {
        print("PFPatientDetailsModel param begin")
        var document_url = ""
        let defaults = NSUserDefaults.standardUserDefaults()
        let awsURLOne = defaults.stringForKey("awsURLOne")
        let awsURLTwo = defaults.stringForKey("awsURLTwo")
        let awsURLThree = defaults.stringForKey("awsURLThree")
        let awsURLFour = defaults.stringForKey("awsURLFour")
        videoStatus1 = defaults.stringForKey("completedVideoStatus1")
        videoStatus2 = defaults.stringForKey("completedVideoStatus2")
        videoStatus3 = defaults.stringForKey("completedVideoStatus3")
        videoStatus4 = defaults.stringForKey("completedVideoStatus4")
        if let temp = defaults.objectForKey("doc") as? String
        {
            document_url = temp
        }
        if (videoStatus1==nil) {
            videoStatus1 = "In progress"
        }
        if (videoStatus2==nil) {
            videoStatus2 = "In progress"
        }
        if (videoStatus3==nil) {
            videoStatus3 = "In progress"
        }
        if (videoStatus4==nil) {
            videoStatus4 = "In progress"
        }
        let parameters1 = [
            "clinical_trial_id": clinical_trial_id,
            "patient_name": patient_name,
            "patient_id": patient_id,
            "age_id": age_id,
            "gender_id": gender_id,
            "ethinicity_id": ethinicity_id,
            "video_url_1": awsURLOne! as NSString,
            "video_url_2": awsURLTwo! as NSString,
            "video_url_3": awsURLThree! as NSString,
            "video_url_4": awsURLFour! as NSString,
            "video_status_1": videoStatus1,
            "video_status_2": videoStatus2,
            "video_status_3": videoStatus3,
            "video_status_4": videoStatus4,
            "language_id": language_id,
            "encounter_id": encounterID,
            "document_url": document_url,
            "images": []
        ]
        print(parameters1)
        do {
            let json = try NSJSONSerialization.dataWithJSONObject(parameters1, options: NSJSONWritingOptions())
            print(json)
            urlRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters1, options: NSJSONWritingOptions())
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("JSON serialization Error!")
        }
        print("PFPatientDetailsModel param end")
        return urlRequest
    }

}
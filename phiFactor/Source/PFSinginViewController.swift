//
//  PFSinginViewController.swift
//  PhiFactor
//
//  Created by Apple on 20/05/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import MessageUI

/// Getting the mandatory and non mandatory details of the patient.
class PFSinginViewController: GAITrackedViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, ABPadLockScreenSetupViewControllerDelegate, ABPadLockScreenViewControllerDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet var tapGuest: UITapGestureRecognizer!
    @IBOutlet weak var PFSHbackrongimage: UIImageView!
    @IBOutlet var guestureView: UIView!
    @IBOutlet var uploadStatusView: UIView!
    @IBOutlet var closePicker: UIButton!
    @IBOutlet weak var pauseaction: UIButton!
    @IBOutlet weak var pickerbuttonaction: UIButton!
    @IBOutlet weak var patientdetails: UITableView!
    @IBOutlet weak var startvedio: UIButton!
    @IBOutlet weak var howtotakevedio: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var vediouplayerlayer: UIView!
    @IBOutlet var pfsHowtoTakeVideoView: UIView!
    @IBOutlet var PFSbaseview: UIView!
    @IBOutlet weak var stopdemovedio: UIButton!
    @IBOutlet weak var startdemovedio: UIButton!
    @IBOutlet weak var pickerview: UIPickerView!
    @IBOutlet var imageActivityView: UIImageView!
    @IBOutlet var popView: UIView!
    @IBOutlet var docScanSwitch: SevenSwitch!
  
    private(set) var thePin: String?
    var unlocked = false;
    var pinUnlockTimer: NSTimer!
    var canShowVideoUploadAlert = false
    var rowcount: NSInteger=0
    var cameraModel: PFCameraScreenModel?
    var patientModel: PFPatientDetailsModel?
    var avPlayer1 = AVPlayer()
    var avPlayerLayer1: AVPlayerLayer!
    var currentTime: Float!
    var totalDuration: Float!
    var duration: CMTime!
    var timeInSecond: Float!
    var newtime: CMTime!
    var myTimer: NSTimer!
    var patientID: String!
    var patientAge: NSNumber!
    var patientName: String!
    var encounterID: String!
    var istextend2: Bool!
    var playerlayer: Bool!
    var tap: UITapGestureRecognizer!
    var access_token: String!
    var token_type: String!
    let button = UIButton(type: UIButtonType.Custom)
    var progressview: UIView!
    var pickframe: CGRect!
    var patientDetailList: [String] = ["Clinical Trail", "Patient Name", "Patient ID", "Age", "Gender", "Ethnicity", "Language Spoken", "Encounter ID"]
    var warningdetaillist: [String] = ["Enter clinical trail", "Enter patient name", "Enter patient id", "Enter age", "Enter gender", "Enter ethnicity", "Enter language", "Enter Encounter ID"]
    var patientDetailListImage: [String] = ["PFSd_Clinical_Trail", "PFSd_patient_name", "PFSd_patient_id", "PFSd_Age", "PFSd_Gender", "PFSd_Eteniticity", "PFSd_language", "PFSd_language"]

    override func viewDidLoad() {
        super.viewDidLoad()
        print("PatientScreen viewDidLoad begin")
        pinUnlockTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector(PFSinginViewController.resetUnlockFlag), userInfo: nil, repeats: true)
        self.screenName = PFSinginViewControllerScreenName
        if canShowVideoUploadAlert {
            showUploadStatusAlert()
        }
        let isDocScanOn = NSUserDefaults.standardUserDefaults().boolForKey("isDocScanOn")
        if isDocScanOn != false
        {
            docScanSwitch.setOn(true, animated: false)
        }
        else
        {
            docScanSwitch.setOn(false, animated: false)
        }
        print("PatientScreen viewDidLoad end")
    }

    /**
     Tap guesture action which hides the popup with animation.

     - parameter sender: tap guesture from interface.
     */

    @IBAction func tapAction(sender: AnyObject) {
        print("PatientScreen tapAction begin")
         guestureView.hidden = true
        UIView.animateWithDuration(0.5, animations: {
            self.popView.frame = CGRectMake(self.popView.frame.origin.x, self.popView.frame.origin.y, self.popView.frame.width, 0)
            }, completion: { (isCompleted) in
                if isCompleted {
                    self.popView.hidden = true
                }
        })
        UIView.commitAnimations()
        print("PatientScreen tapAction end")
    }

    /**
     Popup button action which animates the popup view hide if its already shown and vice versa.
     */

    @IBAction func presentPopUp() {
        print("PatientScreen presentPopUp begin")
        if self.popView.frame.size.height == 210 {
            guestureView.hidden = true
            UIView.animateWithDuration(0.5, animations: {
                self.popView.frame = CGRectMake(self.popView.frame.origin.x, self.popView.frame.origin.y, self.popView.frame.width, 0)
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.popView.hidden = true
                    }
            })
            UIView.commitAnimations()
            }
        else {
            guestureView.hidden = false
            popView.frame = CGRectMake(popView.frame.origin.x, popView.frame.origin.y, popView.frame.width, 0)
            UIView.animateWithDuration(0.5) {
                self.popView.hidden = false
                self.popView.frame = CGRectMake(self.popView.frame.origin.x, self.popView.frame.origin.y, self.popView.frame.width, 210)
            }
            UIView.commitAnimations()
        }
        print("PatientScreen presentPopUp end")
    }

    /**
     Loading inial data
     Service - Rest Service API
     For Web service Calling - Alamofire Framework used
     URL Format - "baseURL/load_initial_data?Authorization=token_type&access_token=access_token_value"
     */

    func loadvalues() {
        print("PatientScreen loadvalues begin")
        PFGlobalConstants.sendEventWithCatogory("background", action: "functionCall", label: "loadValues", value: nil)
        let app_version : Int = Int(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String)!
        requestString = "\(baseURL)/load_initial_data?Authorization=\(token_type)&access_token=\(access_token)&app_version=\(app_version)"
        print(requestString)
        url1 = NSURL(string: requestString as String)!
        urlRequest = NSMutableURLRequest(URL: url1)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.HTTPMethod = Alamofire.Method.GET.rawValue
        Alamofire.request(urlRequest)
            .responseJSON { response in
                // do whatever you want here
                switch response.result {
                case .Failure( let error):
                    print(error)
                    let httpStatusCode = response.response?.statusCode
                    print(httpStatusCode)
                    if(httpStatusCode==401) {
                        print("Invalid access token")
                        PFGlobalConstants.sendException("InvalidAccessToken", isFatal: false)
                        self.getRefreshToken()
                    }
                case .Success(let responseObject):
                    print(responseObject)
                    let response = responseObject as! NSDictionary
                    print(response)
                    let languages = response.objectForKey("language")! as! NSArray
                    let clinicalTrialArray = response.objectForKey("clinical_trial")! as! NSArray
                    for obj in clinicalTrialArray {
                        let objDic = obj as? NSDictionary
                        let arrayValue = objDic?.objectForKey("ct_name") as? String
                        let defaultValue = response.objectForKey("default_tag") as? String
                        if (arrayValue == defaultValue) {
                            clinical_id = objDic?.objectForKey("ct_id") as? NSNumber
                            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                            let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
                            cell.celltextchossen.text = objDic?.objectForKey("ct_name") as? String
                        }
                    }
                    print(languages)
                    self.patientModel?.getResonse(response) // request send to the PFPatientDetailsModel and get the response
                    //                    [self.patientdetails]
                }
                print("PatientScreen loadvalues end")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    /**
     picker view delgate
     - parameter pickerView: Used to display patient details load values
     - Pickerview: set in the StoryBoard
     - returns: returns the # of rows in each component..
     */

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerview.tag==0 {
            if(clinical_trials_name_arr.count==0) {
                let novalue = "No Values"
                cliical_trains_novalue.addObject(novalue)
                pickerbuttonaction.hidden=true
                return 1

            }
            else {

                return clinical_trials_name_arr.count
            }
        }
        else if pickerview.tag==4 {
            return gender_name_arr.count
        }
        else if pickerview.tag==6 {
            return languages_name_arr.count
        }
        else if pickerview.tag==5 {
            return ethincity_name_arr.count
        }


        return 1
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        if pickerview.tag==0 {
            if(clinical_trials_name_arr.count==0) {
                return cliical_trains_novalue[0] as? String
            }
            else {

                return clinical_trials_name_arr[row] as? String
            }
        }
        else if pickerview.tag==4 {
            return gender_name_arr[row] as? String
        }
        else if pickerView.tag==6 {
            return languages_name_arr[row] as? String
        }
        else if pickerView.tag==5 {
            return ethincity_name_arr[row] as? String
        }

        return ""
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.patientDetailList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.patientdetails.dequeueReusableCellWithIdentifier("cell")! as! PFSiginuptablecellTableViewCell
        let patientDetailListstring=self.patientDetailList[indexPath.row]
                if(patientDetailListstring .isEqual("Patient Name")||patientDetailListstring .isEqual("Patient ID")||patientDetailListstring .isEqual("Age")||patientDetailListstring .isEqual("Encounter ID")) {

                    cell.celltextchossen.attributedPlaceholder = NSAttributedString(string: "Type Here",
                                                                                    attributes: [ NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
            cell.userInteractionEnabled=true
            cell.celldiscloserbutton.hidden=true
            cell.cellstepdiscloserbutton.hidden=true
            cell.celltextchossen.hidden=false
            cell.celltextchossen.enabled=false
        }
        else {

            cell.celldiscloserbutton.hidden=false
            cell.celltextchossen.attributedPlaceholder = NSAttributedString(string: "Choose Here",
                                                                                    attributes: [ NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
            cell.cellstepdiscloserbutton.hidden=false
            cell.userInteractionEnabled=true
            cell.celltextchossen.hidden=false
            cell.celltextchossen.enabled=false
            cell.celldiscloserbutton.tag=indexPath.row
            cell.cellstepdiscloserbutton.tag=indexPath.row
        }
        cell.celltextdetails?.text=patientDetailListstring
        let patientDetailListImagestring=self.patientDetailListImage[indexPath.row]
        cell.cellimage!.image=UIImage(named: patientDetailListImagestring)
        rowcount=indexPath.row
        if(rowcount % 2==0) {
            cell.backgroundColor=UIColor .clearColor()
        }
        else {

            cell.backgroundColor=UIColor .whiteColor()
        }
        cell.celldiscloserbutton.tag=indexPath.row
        cell.cellstepdiscloserbutton.tag=indexPath.row
        cell.celltextchossen.tag=indexPath.row

        cell.celldiscloserbutton.addTarget(self, action: #selector

            (PFSinginViewController.pickerviewdata(_: )), forControlEvents: .TouchUpInside)
        cell.cellstepdiscloserbutton.addTarget(self, action: #selector

            (PFSinginViewController.pickerviewdata(_: )), forControlEvents: .TouchUpInside)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        rowcount=indexPath.row
        button.hidden=true
        let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
        cell.celltextchossen.hidden=false
        // picker resize
        var framepicker: CGRect!
        framepicker=pickerview.frame
        framepicker.origin.y=self.view.frame.size.height
        pickerview.frame=framepicker
        // pickerdone button resize
        var framepickerbuttonaction: CGRect!
        framepickerbuttonaction=pickerbuttonaction.frame
        framepickerbuttonaction.origin.y=self.view.frame.size.height
        pickerbuttonaction.frame=framepickerbuttonaction
        // picker closebutton resize
        var frameclosePicker: CGRect!
        frameclosePicker=closePicker.frame
        frameclosePicker.origin.y=self.view.frame.size.height
        closePicker.frame=frameclosePicker
        // picker view and it button
        pickerbuttonaction.hidden=false
        closePicker.hidden=false
        pickerview.hidden = false
        if(rowcount==1||rowcount==2||rowcount==3||rowcount==7) {
            cell.celltextchossen.hidden=false
            cell.celltextchossen.delegate=self
            cell.celltextchossen.enabled=true
            if(rowcount==1 || rowcount == 2||rowcount==7) {
                cell.celltextchossen.keyboardType = UIKeyboardType.Alphabet
            }
            else {
                cell.celltextchossen.keyboardType = UIKeyboardType.NumberPad
            }
        }
        else {
            UIDevice.currentDevice().batteryLevel
            self.patientdetails.userInteractionEnabled=false
                // pickerview
            var framepicker2: CGRect!
            framepicker2=pickerview.frame
            framepicker2.origin.y=self.view.frame.size.height-pickerview.frame.size.height-150
                // pickerdone button resize
            var framepickerbuttonaction2: CGRect!
            framepickerbuttonaction2=pickerbuttonaction.frame
            framepickerbuttonaction2.origin.y=self.view.frame.size.height-pickerbuttonaction.frame.size.height
                // picker closebutton resize
            var frameclosePicker2: CGRect!
            frameclosePicker2=closePicker.frame
            frameclosePicker2.origin.y=self.view.frame.size.height-closePicker.frame.size.height
            UIView.animateWithDuration(0.50, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                    self.pickerbuttonaction.frame=framepickerbuttonaction2
                    self.pickerview.frame=framepicker2
                    self.closePicker.frame=frameclosePicker2
                }, completion: nil)
            pickerview.tag=rowcount
            pickerview.hidden = false
            howtotakevedio.hidden=true
            startvedio.hidden=true
            pickerview.delegate = self
            self.view.endEditing(true)
            pickerbuttonaction.hidden=false
            closePicker.hidden=false
            var celltextdetailmoveup: CGRect
            celltextdetailmoveup = (cell.celltextdetails?.frame)!
            celltextdetailmoveup.origin.y=0
            UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                cell.celltextdetails?.frame=celltextdetailmoveup
            }, completion: nil)
            cell.celltextdetails.font = UIFont(name: "calibri", size: 12)
            var celltextchossen: CGRect
            celltextchossen=cell.celltextchossen.frame
            celltextchossen.origin.y=15
            celltextchossen.origin.x=(cell.celltextdetails?.frame.origin.x)!
            celltextchossen.size.width=(cell.celltextdetails?.frame.size.width)!+60
            UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                cell.celltextchossen?.frame=celltextchossen
                cell.celltextchossen?.translatesAutoresizingMaskIntoConstraints = true
                cell.celltextdetails?.translatesAutoresizingMaskIntoConstraints = true
            }, completion: nil)
        }
    }

    /**
     Displaying the view as a video player which presents the user to how to take a video.

     - parameter sender: howtotakevideo information button from interface.
     */

    @IBAction func howtotakevideo(sender: AnyObject) {
//       self.closePicker.hidden=true
//        self.pickerbuttonaction.hidden=true
//
//        pfsHowtoTakeVideoView.frame.size.width=PFSbaseview.frame.size.width
//        pfsHowtoTakeVideoView.frame.size.height=PFSbaseview.frame.size.height
//        pfsHowtoTakeVideoView.frame.origin.x=0
//        pfsHowtoTakeVideoView.frame.origin.y=PFSbaseview.frame.size.height
//        PFSbaseview .addSubview(pfsHowtoTakeVideoView)
//
//        var setframe=pfsHowtoTakeVideoView.frame
//        setframe.size.width=pfsHowtoTakeVideoView.frame.size.width
//        setframe.size.height=pfsHowtoTakeVideoView.frame.size.height
//        setframe.origin.y=0
//        setframe.origin.x=0
//        UIView.animateWithDuration(1.0, delay: 0.10, options: UIViewAnimationOptions.TransitionCurlUp, animations: {
//            self.pfsHowtoTakeVideoView.frame=setframe
//        }, completion: nil)
//
//        avPlayerLayer1 = AVPlayerLayer(player: avPlayer1)
//        let path2 = NSBundle.mainBundle().pathForResource("fullVideo", ofType: "mp4")
//        let url = NSURL.fileURLWithPath(path2!)
//        let playerItem = AVPlayerItem(URL: url)
//        avPlayer1.replaceCurrentItemWithPlayerItem(playerItem)
//        NSNotificationCenter.defaultCenter().addObserver(self,
//                                                         selector: #selector(PFSinginViewController.restartdemoVideoFromBeginning),
//                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
//                                                         object: avPlayer1.currentItem)
//        self.pfsHowtoTakeVideoView.layer.insertSublayer(avPlayerLayer1, atIndex: 0)
//        avPlayerLayer1.frame = self.pfsHowtoTakeVideoView.bounds
//        avPlayer1.pause()
        print("PatientScreen howtotakevideo begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "HowToTakeVideo", value: nil)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("VideoPreviewView") as! VideoPreviewView
        nextViewController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        let path2 = NSBundle.mainBundle().pathForResource("fullVideo", ofType: "mp4")
        let url = NSURL.fileURLWithPath(path2!)
        nextViewController.itemUrl = url
        nextViewController.isPresentedView = true
        self.presentViewController(nextViewController, animated: true, completion: nil)
        print("PatientScreen howtotakevideo end")
    }

    /**
     Automatically Restarts the howtotakevideo after end of video playing.
     */
    func restartdemoVideoFromBeginning() {

        let seconds: Int64 = 0
        let preferredTimeScale: Int32 = 1
        let seekTime: CMTime = CMTimeMake(seconds, preferredTimeScale)
        avPlayer1.seekToTime(seekTime)
        avPlayer1.pause()
        PFSHbackrongimage.hidden=false
        pauseaction.hidden=true
        stopdemovedio.hidden=false
    }

    /**
     Cancel Button Action: - remove the demo video when cancel button click
     - parameter sender: Cancel button in the interface
     */

    @IBAction func removedemovediou(sender: AnyObject) {
        if(playerlayer==true) {
            avPlayerLayer1.removeFromSuperlayer()
            avPlayer1.pause()
            avPlayerLayer1.hidden=true
        }
        slider.hidden=true
        PFSHbackrongimage.hidden=false
        var setframe=pfsHowtoTakeVideoView.frame
        pauseaction.hidden=true
        stopdemovedio.hidden=false
        setframe.size.width=pfsHowtoTakeVideoView.frame.size.width
        setframe.size.height=pfsHowtoTakeVideoView.frame.size.height
        setframe.origin.y=0-pfsHowtoTakeVideoView.frame.size.height
        setframe.origin.x=0
        UIView.animateWithDuration(1.0, delay: 0.10, options: UIViewAnimationOptions.TransitionCurlUp, animations: {
            self.pfsHowtoTakeVideoView.frame=setframe
        }, completion: nil)
        stopdemovedio.setImage(UIImage(named: "PFH_playbutton.png"), forState: UIControlState.Normal)
    }

    /**
     Playing the howtotakevideo when it was paused.

     - parameter sender: paly button from interface.
     */

    @IBAction func playdemovediou(sender: AnyObject) {

        avPlayer1.play()
        slider.hidden=false
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(PFSinginViewController.updateSlider), userInfo: nil, repeats: true)
        slider.addTarget(self, action: #selector(PFSinginViewController.sliderValueDidChange(_: )), forControlEvents: UIControlEvents.ValueChanged)
        slider.minimumValue = 0.0
        slider.continuous = true
        playerlayer=true
        pauseaction.hidden=false
        stopdemovedio.hidden=true
    }

    /**
     Update the slider respect with the video duration.
     */

    func updateSlider() {

        currentTime = Float(CMTimeGetSeconds(avPlayer1.currentTime()))
        duration = avPlayer1.currentItem!.asset.duration
        totalDuration = Float(CMTimeGetSeconds(duration))
        slider.value = currentTime // Setting slider value as current time
        slider.maximumValue = totalDuration // Setting maximum value as total duration of the video
    }

    /**
     Update the video current time respect with the slider value.

     - parameter sender: slider from interface.
     */

    func sliderValueDidChange(sender: UISlider!) {
        timeInSecond=slider.value
        newtime = CMTimeMakeWithSeconds(Double(timeInSecond), 1)// Setting new time using slider value
        avPlayer1.seekToTime(newtime)
    }

    func pickerviewdata(sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
        pickerview.tag=sender.tag
        pickerview.hidden = false
        howtotakevedio.hidden=true
        startvedio.hidden=true
        pickerview.delegate = self
        self.view.endEditing(true)
        pickerbuttonaction.hidden=false
        closePicker.hidden=false
        self.rowcount=sender.tag
        self.patientdetails.userInteractionEnabled=false
        // pickerview
        var framepicker2: CGRect!
        framepicker2=pickerview.frame
        framepicker2.origin.y=self.view.frame.size.height-pickerview.frame.size.height-150
        // pickerdone button resize
        var framepickerbuttonaction2: CGRect!
        framepickerbuttonaction2=pickerbuttonaction.frame
        framepickerbuttonaction2.origin.y=self.view.frame.size.height-pickerbuttonaction.frame.size.height
        // picker closebutton resize
        var frameclosePicker2: CGRect!
        frameclosePicker2=closePicker.frame
        frameclosePicker2.origin.y=self.view.frame.size.height-closePicker.frame.size.height
        UIView.animateWithDuration(0.50, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                self.pickerbuttonaction.frame=framepickerbuttonaction2
                self.pickerview.frame=framepicker2
                self.closePicker.frame=frameclosePicker2
            }, completion: nil)
        var celltextdetailmoveup: CGRect
        celltextdetailmoveup = (cell.celltextdetails?.frame)!
        celltextdetailmoveup.origin.y=0
        UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                cell.celltextdetails?.frame=celltextdetailmoveup
            }, completion: nil)
        cell.celltextdetails.font = UIFont(name: "calibri", size: 12)
        var celltextchossen: CGRect
        celltextchossen=cell.celltextchossen.frame
        celltextchossen.origin.y=15
        celltextchossen.origin.x=(cell.celltextdetails?.frame.origin.x)!
        celltextchossen.size.width=(cell.celltextdetails?.frame.size.width)!+60
        UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                        cell.celltextchossen?.frame=celltextchossen
                cell.celltextchossen?.translatesAutoresizingMaskIntoConstraints = true
                cell.celltextdetails?.translatesAutoresizingMaskIntoConstraints = true
            }, completion: nil)
    }

   @IBAction func picker_clse(sender: AnyObject) {
        var framepicker2: CGRect!
        framepicker2=pickerview.frame
        framepicker2.origin.y=self.view.frame.size.height// -pickerview.frame.size.height-150
        // pickerdone button resize
        var framepickerbuttonaction2: CGRect!
        framepickerbuttonaction2=pickerbuttonaction.frame
        framepickerbuttonaction2.origin.y=self.view.frame.size.height// -pickerview.frame.size.height-100
        // picker closebutton resize
        var frameclosePicker2: CGRect!
        frameclosePicker2=closePicker.frame
        frameclosePicker2.origin.y=self.view.frame.size.height// -closePicker.frame.size.height
        UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                self.pickerbuttonaction.frame=framepickerbuttonaction2
                self.pickerview.frame=framepicker2
                self.closePicker.frame=frameclosePicker2
            }, completion: nil)
        // pickerbuttonaction.hidden=true
        // pickerview.hidden=true
        let seconds = 0.40
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                // here code perfomed with delay
            self.howtotakevedio.hidden=false
            self.startvedio.hidden=false
            self.patientdetails.userInteractionEnabled=true
        })
      }

    override func viewDidAppear(animated: Bool) {
        print("PatientScreen viewDidAppear begin")
        guestureView.hidden = true
        UIView.animateWithDuration(0.0) {
            self.popView.frame = CGRectMake(self.popView.frame.origin.x, self.popView.frame.origin.y, self.popView.frame.width, 0)
        }
        // Popup
        self.popView.hidden = true
        self.popView.layer.shadowColor = UIColor.blackColor().CGColor
        self.popView.layer.shadowOpacity = 0.6
        self.popView.layer.shadowRadius = 3.0
        self.popView.layer.cornerRadius = 3.0
        self.popView.layer.shadowOffset = CGSizeMake(-2.0, 2.0)
        UIView.animateWithDuration(0.0) {
            self.popView.frame = CGRectMake(self.popView.frame.origin.x, self.popView.frame.origin.y, self.popView.frame.width, 0)
        }
        UIView.commitAnimations()
        self.popView.clipsToBounds = true
        self.popView.layer.masksToBounds = true
        print("PatientScreen viewDidAppear end")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("PatientScreen viewWillAppear begin")
        unlocked = false
        // Start the playback
        self.popView.hidden = true
        closePicker.hidden=true
        pickerbuttonaction.hidden=true
        cameraModel = PFCameraScreenModel()
        // to make picker data emptly
        clinical_trials_name_arr.removeAllObjects()
        gender_name_arr.removeAllObjects()
        languages_name_arr.removeAllObjects()
        ethincity_name_arr.removeAllObjects()
        patientModel=PFPatientDetailsModel()
        let defaults = NSUserDefaults.standardUserDefaults()
        playerlayer=false
        access_token = defaults.stringForKey("access_token")
        token_type = defaults.stringForKey("token_type")
        istextend2=true
        [self.loadvalues()]
        pickerview.delegate=self
        pickerview.showsSelectionIndicator=false
        button.setTitle("Return", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        button.frame = CGRectMake(0, 163, 106, 53)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(PFSinginViewController.doneAction(_: )), forControlEvents: UIControlEvents.TouchUpInside)
        button.hidden=true
        self.progessbar()
        let imageData = NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("loading", withExtension: "gif")!)
        imageActivityView.image = UIImage.gifWithData(imageData!)
        imageActivityView.hidden = true
        print("PatientScreen viewWillAppear begin")
    }

    override func viewDidDisappear(animated: Bool) {
        progressbarhidden()
        imageActivityView.hidden = true
    }

    func textFieldDidEndEditing(textField: UITextField) {  print(rowcount)

        if(rowcount==2) {
            self.rowcount=2
            let indexPath = NSIndexPath(forRow: 2, inSection: 0)
            let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
            patientName = cell.celltextchossen.text
            button.hidden=true
            print(patientName)
            }
        else if(rowcount==1) {
            self.rowcount=1
            let indexPath = NSIndexPath(forRow: 1, inSection: 0)
            let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
            patientID = cell.celltextchossen.text
            button.hidden=true
            print(patientID)
            }
        else if(rowcount==3) {
            self.rowcount=3
            let indexPath = NSIndexPath(forRow: 3, inSection: 0)
            let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
            patientAge = Int(cell.celltextchossen.text!)
            button.hidden=true

        }
        else if(rowcount==7) {
            self.rowcount=7
            let indexPath = NSIndexPath(forRow: 7, inSection: 0)
            let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
            encounterID = cell.celltextchossen.text
            button.hidden=true
        }
    }

    /**
     start Video action
     - parameter sender: Validating all the fields in the tableview
     */

    @IBAction func startvedioaction(sender: AnyObject) {
        print("PatientScreen startvedioaction begin")
        startvedio.hidden = true
        dispatch_async(dispatch_get_main_queue()) { 
            var valid: Bool!
            var indexPath = NSIndexPath(forRow: 1, inSection: 0)
            var cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
            self.patientName = cell.celltextchossen.text
            print(self.patientName)
            indexPath = NSIndexPath(forRow: 2, inSection: 0)
            cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
            self.patientID = cell.celltextchossen.text
            print(self.patientID)
            
            indexPath = NSIndexPath(forRow: 3, inSection: 0)
            cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
            self.patientAge = Int(cell.celltextchossen.text!)
            indexPath = NSIndexPath(forRow: 7, inSection: 0)
            cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
            self.encounterID = cell.celltextchossen.text
            print("Validation Start")
            valid=true
            let someInts: [Int] = [0, 1, 2, 3, 4]
            for index in someInts {
                print("Value of  index is \(index)")
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
                if(cell.celltextchossen.text=="") {
                    let warningetailliststring=self.warningdetaillist[indexPath.row] as String
                    cell.celltextchossen.attributedPlaceholder = NSAttributedString(string: warningetailliststring,
                                                                                    attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
                    var celltextdetailmoveup: CGRect
                    celltextdetailmoveup = (cell.celltextdetails?.frame)!
                    celltextdetailmoveup.origin.y=15
                    UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                        cell.celltextdetails?.frame=celltextdetailmoveup
                        }, completion: nil)
                    cell.celltextdetails.font = UIFont(name: "calibri", size: 12)
                    var celltextchossen: CGRect
                    celltextchossen=cell.celltextchossen.frame
                    celltextchossen.origin.y=15
                    celltextchossen.origin.x=142
                    celltextchossen.size.width=(cell.celltextchossen?.frame.size.width)!+60
                    UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                        cell.celltextchossen?.frame=celltextchossen
                        cell.celltextchossen?.translatesAutoresizingMaskIntoConstraints = true
                        cell.celltextdetails?.translatesAutoresizingMaskIntoConstraints = true
                        }, completion: nil)
                    
                    valid=false
                }
                else if indexPath.row == 2 {
                    if cell.celltextchossen.text?.characters.count < 5 || cell.celltextchossen.text?.characters.count > 25 {
                        cell.celltextchossen.text = ""
                        let warningetailliststring = "Patient Id should be 5 to 25 characters"
                        cell.celltextchossen.attributedPlaceholder = NSAttributedString(string: warningetailliststring, attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
                        var celltextdetailmoveup:CGRect
                        celltextdetailmoveup = (cell.celltextdetails?.frame)!
                        celltextdetailmoveup.origin.y=15
                        UIView.animateWithDuration(0.40, delay: 0, options:UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                            cell.celltextdetails?.frame=celltextdetailmoveup
                            }, completion: nil)
                        cell.celltextdetails.font = UIFont(name: "calibri", size: 12)
                        var celltextchossen: CGRect
                        celltextchossen=cell.celltextchossen.frame
                        celltextchossen.origin.y=15
                        celltextchossen.origin.x=142
                        celltextchossen.size.width=(cell.celltextchossen?.frame.size.width)!+60
                        UIView.animateWithDuration(0.40, delay: 0, options:UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                            cell.celltextchossen?.frame=celltextchossen
                            cell.celltextchossen?.translatesAutoresizingMaskIntoConstraints = true
                            cell.celltextdetails?.translatesAutoresizingMaskIntoConstraints = true
                            }, completion: nil)
                        valid=false
                    }
                }
                else if indexPath.row == 3 {
                    if cell.celltextchossen.text == "0" || cell.celltextchossen.text == "00" {
                        cell.celltextchossen.text = ""
                        let warningetailliststring = "Age should not zero"
                        cell.celltextchossen.attributedPlaceholder = NSAttributedString(string: warningetailliststring,
                                                                                        attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
                        var celltextdetailmoveup: CGRect
                        celltextdetailmoveup = (cell.celltextdetails?.frame)!
                        celltextdetailmoveup.origin.y=15
                        UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                            cell.celltextdetails?.frame=celltextdetailmoveup
                            }, completion: nil)
                        cell.celltextdetails.font = UIFont(name: "calibri", size: 12)
                        var celltextchossen: CGRect
                        celltextchossen=cell.celltextchossen.frame
                        celltextchossen.origin.y=15
                        celltextchossen.origin.x=142
                        celltextchossen.size.width=(cell.celltextchossen?.frame.size.width)!+60
                        UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                            cell.celltextchossen?.frame=celltextchossen
                            cell.celltextchossen?.translatesAutoresizingMaskIntoConstraints = true
                            cell.celltextdetails?.translatesAutoresizingMaskIntoConstraints = true
                            }, completion: nil)
                        valid=false
                    }
                }
                else {
                }
            }
            
            
            if(valid==true) {
                
                let defaults = NSUserDefaults.standardUserDefaults()
                
                defaults.setObject (clinical_id, forKey: "clinical_id")
                defaults.setObject (self.patientName, forKey: "patient_name")
                defaults.setObject (self.patientID, forKey: "patient_id")
                defaults.setObject (self.patientAge, forKey: "patient_age")
                defaults.setObject (gender_id, forKey: "gender_id")
                if Ethinicity_id != nil {
                    defaults.setObject (Ethinicity_id, forKey: "ethen_id")
                }
                else
                {
                    defaults.setObject (87, forKey: "ethen_id")
                }
                if language_id != nil {
                    defaults.setObject (language_id, forKey: "lan_id")
                }
                else
                {
                    defaults.setObject (51, forKey: "lan_id")
                }
                defaults.setObject(self.encounterID, forKey: "encounterID")
                
//                if self.progressview == nil {
//                    self.progessbar()
//                }
                self.imageActivityView.hidden = false
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), {
                    //            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    //            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PFCameraviewcontrollerscreen") as! PFCameraviewcontrollerscreen
                    let isDocScanOn = NSUserDefaults.standardUserDefaults().boolForKey("isDocScanOn")
                    if isDocScanOn == true
                    {
                        self.navigationController?.pushViewController(IOViewController(), animated: false)

                    }
                    else
                    {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PFCameraviewcontrollerscreen") as! PFCameraviewcontrollerscreen
                        self.navigationController?.pushViewController(nextViewController, animated: false)
                    }
                    self.startvedio.hidden = false
                    print("PatientScreen startvedioaction end")
                })
                return
            }
            else {
                print("Validation fails")
                self.startvedio.hidden = false
                print("PatientScreen startvedioaction end")
            }
        }
        

    }

    /**
     ProgressBar
      - parameter passview: Adding a gif file for progressbar and setting the frame in the view
     */

    func progessbar(passview: UIView) {

        var baseviewframe: CGRect!
        baseviewframe=passview.frame
        progressview=UIView(frame: baseviewframe)

        let progressviewimage=UIView(frame: CGRectMake((progressview.frame.size.width/2)-16, (progressview.frame.size.height/2-14), 32, 32))
        var progressviewimagegif: UIImageView!
        let imageData = NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("loading", withExtension: "gif")!)
        let advTimeGif = UIImage.gifWithData(imageData!)
        progressviewimagegif = UIImageView(image: advTimeGif)
        progressviewimagegif.frame.size.width=progressviewimage.frame.size.width
        progressviewimagegif.frame.size.height=progressviewimage.frame.size.height
        progressviewimage.addSubview(progressviewimagegif)

        progressview.backgroundColor=UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1)
        progressview.addSubview(progressviewimage)
        self.view.addSubview(progressview)
        progressview.hidden=true

    }

    /**
     Validating the textfields on the table
      - parameter textField: Checking textField Validation
     - parameter range:     Checking the character range for Age,Name,id
     - parameter string: Checks the current string in the textField
      - returns: It return "True" if the condition is satisfied or "False"
     */

    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange,
                                                 replacementString string: String)
        -> Bool {

        if(textField.tag==1) {
            print("patientName")
                            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
            return prospectiveText.containsOnlyCharactersIn("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ")
        }
        else if(textField.tag==2) {
                   print("patientID")
                let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
            return prospectiveText.containsOnlyCharactersIn("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") &&
                prospectiveText.characters.count <= 25
        }
        else if(textField.tag==3) {
            print("patientAge")
                let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
            return prospectiveText.containsOnlyCharactersIn("0123456789") &&
                prospectiveText.characters.count <= 2
    //            let invalidCharacters = NSCharacterSet(charactersInString: "0123456789").invertedSet
//            return string.rangeOfCharacterFromSet(invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil && string.characters.count <= 2
        }
        else if(textField.tag==7) {
            print("patientID")
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
            return prospectiveText.containsOnlyCharactersIn("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789") &&
                prospectiveText.characters.count <= 30
        }


        if string.characters.count == 0 {
            return true
        }
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    /**
     picker_action
      - parameter sender: Display the selected value in the tableViewCell using pickerView
     */

    @IBAction func picker_action(sender: AnyObject) {
        // closePicker.hidden=true
        if pickerview.tag==0 {
                let selectedValue = clinical_trials_name_arr[pickerview.selectedRowInComponent(0)]
            let selectedId = clinical_trials_id_arr[pickerview.selectedRowInComponent(0)]
                print(selectedId)
            print(selectedValue)
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
            cell.celltextchossen.hidden=false
            cell.celltextchossen.text = selectedValue as? String
            clinical_id  = (clinical_trials_id_arr [pickerview.selectedRowInComponent(0)]) as! NSNumber
        }
        else if pickerview.tag==4 {
                    let selectedValue = gender_name_arr[pickerview.selectedRowInComponent(0)]
            print(selectedValue)
            gender_id  = (gender_id_arr [pickerview.selectedRowInComponent(0)]) as! NSNumber
            let indexPath = NSIndexPath(forRow: 4, inSection: 0)
            let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
            cell.celltextchossen.hidden=false
            cell.celltextchossen.text = selectedValue as? String
        }
            else if pickerview.tag==6 {
                let selectedValue = languages_name_arr[pickerview.selectedRowInComponent(0)]
            print(selectedValue)
            let indexPath = NSIndexPath(forRow: 6, inSection: 0)
            let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
            cell.celltextchossen.hidden=false
            language_id  = (languages_id_arr [pickerview.selectedRowInComponent(0)]) as! NSNumber
            cell.celltextchossen.text = selectedValue as? String
        }
                else if pickerview.tag==5 {
                let selectedValue = ethincity_name_arr[pickerview.selectedRowInComponent(0)]
            print(selectedValue)
            let indexPath = NSIndexPath(forRow: 5, inSection: 0)
            let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
            cell.celltextchossen.hidden=false
            Ethinicity_id  = (ethincity_id_arr [pickerview.selectedRowInComponent(0)]) as! NSNumber
            cell.celltextchossen.text = selectedValue as? String
        }
          var framepicker2: CGRect!
        framepicker2=pickerview.frame
        framepicker2.origin.y=self.view.frame.size.height // -pickerview.frame.size.height-150
        // pickerdone button resize
        var framepickerbuttonaction2: CGRect!
        framepickerbuttonaction2=pickerbuttonaction.frame
        framepickerbuttonaction2.origin.y=self.view.frame.size.height // -pickerview.frame.size.height-100
        // picker closebutton resize
        var frameclosePicker2: CGRect!
        frameclosePicker2=closePicker.frame
        frameclosePicker2.origin.y=self.view.frame.size.height // -closePicker.frame.size.height
        UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                self.pickerbuttonaction.frame=framepickerbuttonaction2
                self.pickerview.frame=framepicker2
                self.closePicker.frame=frameclosePicker2
            }, completion: nil)
        // pickerbuttonaction.hidden=true
        // pickerview.hidden=true
        let seconds = 0.40
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                // here code perfomed with delay
            self.howtotakevedio.hidden=false
            self.startvedio.hidden=false
            self.patientdetails.userInteractionEnabled=true
        })
    }

    @IBAction func pausesbuttonaction(sender: AnyObject) {
        pauseaction.hidden=true
        stopdemovedio.hidden=false
        avPlayer1.pause()
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        print(textField.tag)

        if(textField.tag==1 || textField.tag==2 || textField.tag==7) {
            button.hidden=true
            }
        else {
            button.hidden=false
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PFSinginViewController.keyboardWillShow(_: )), name: UIKeyboardWillShowNotification, object: nil)

        }
        let indexPath = NSIndexPath(forRow: textField.tag, inSection: 0)
        let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
        var celltextdetailmoveup: CGRect
        celltextdetailmoveup = (cell.celltextdetails?.frame)!
        celltextdetailmoveup.origin.y=0
        UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                        cell.celltextdetails?.frame=celltextdetailmoveup
            }, completion: nil)
        cell.celltextdetails.font = UIFont(name: "calibri", size: 12)
        var celltextchossen: CGRect
        celltextchossen=cell.celltextchossen.frame
        celltextchossen.origin.y=15
        celltextchossen.origin.x=(cell.celltextdetails?.frame.origin.x)!
        celltextchossen.size.width=(cell.celltextdetails?.frame.size.width)!+60
        UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                        cell.celltextchossen?.frame=celltextchossen
                cell.celltextchossen?.translatesAutoresizingMaskIntoConstraints = true
                cell.celltextdetails?.translatesAutoresizingMaskIntoConstraints = true
            }, completion: nil)
    }

    func keyboardWillShow(note: NSNotification) -> Void {

        dispatch_async(dispatch_get_main_queue()) { () -> Void in


            let keyBoardWindow = UIApplication.sharedApplication().windows.last
            self.button.frame = CGRectMake(0, (keyBoardWindow?.frame.size.height)!-53, 106, 53)
            keyBoardWindow?.addSubview(self.button)
            keyBoardWindow?.bringSubviewToFront(self.button)

            UIView.animateWithDuration(((note.userInfo! as NSDictionary).objectForKey(UIKeyboardAnimationCurveUserInfoKey)?.doubleValue)!, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in

                self.view.frame = CGRectOffset(self.view.frame, 0, 0)
                }, completion: { (complete) -> Void in
                    print("Complete")

            })
        }

    }

    func doneAction(sender: UIButton) {
        button.hidden=true
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let indexPath = NSIndexPath(forRow: 3, inSection: 0)
            let cell = self.patientdetails.cellForRowAtIndexPath(indexPath) as! PFSiginuptablecellTableViewCell
            cell.celltextchossen.resignFirstResponder()
            self.view.endEditing(true)

        }
    }


    /**
     Adding the progress bar as subview to the given passview.

     - parameter passview: A view which should be a UIView.
     */

    func progessbar() {
        var baseviewframe: CGRect!
        baseviewframe=self.view.frame
        progressview=UIView(frame: baseviewframe)
        let progressviewimage=UIView(frame: CGRectMake((progressview.frame.size.width/2)-16, (progressview.frame.size.height/2-16), 32, 32))
        var progressviewimagegif: UIImageView!
        let imageData = NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("loading", withExtension: "gif")!)
        let advTimeGif = UIImage.gifWithData(imageData!)
        progressviewimagegif = UIImageView(image: advTimeGif)
        progressviewimagegif.frame.size.width=progressviewimage.frame.size.width
        progressviewimagegif.frame.size.height=progressviewimage.frame.size.height
        progressviewimage.addSubview(progressviewimagegif)
        progressview.backgroundColor=UIColor(red: 250.0/255, green: 250.0/255, blue: 250.0/255, alpha: 0.2)
        progressview.addSubview(progressviewimage)
        self.view.addSubview(progressview)
        progressview.hidden=true
    }

    /**
     progress bar create and set it to unhidden
     */

    func progessbarshow() {
        progressview.hidden=false
    }

    /**
     progress bar create and set it to hidden
     */

    func progressbarhidden() {
        progressview.hidden=true
    }

    /**
     Presenting the Upload status view
      - parameter sender: upload status button from inteface.
     */

    @IBAction func UploadStatusAction(sender: AnyObject) {
        print("PatientScreen UploadStatusAction begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "PresentUploadStatusView", value: nil)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PFUploadstatusViewController") as! PFUploadstatusViewController
        nextViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(nextViewController, animated: true, completion: nil)
        print("PatientScreen UploadStatusAction end")
    }

    /**
     Logout Action
      - parameter sender: logout action
     - Removing all session values
     */

    @IBAction func LogoutAction(sender: AnyObject) {
        print("PatientScreen LogoutAction begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "LogOut", value: nil)
        let defaults = NSUserDefaults.standardUserDefaults()
        // defaults.setBool(true, forKey: "UseTouchID")
        defaults.setInteger(1, forKey: "logout")
        defaults.setObject ("", forKey: "access_token")
        defaults.setObject("", forKey: "token_type")
        defaults
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PhiFactorIntro") as! PhiFactorIntro
        nextViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        let nav = UINavigationController(rootViewController: nextViewController)
        nav.navigationBarHidden = true
        let appDelegaet = UIApplication.sharedApplication().delegate as? AppDelegate

        UIView.transitionWithView((appDelegaet?.window)!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            appDelegaet!.window?.backgroundColor = UIColor.whiteColor()
            appDelegaet!.window?.rootViewController = nav
            
            }) { (isCompleted) in
                NSUserDefaults.standardUserDefaults().removeObjectForKey("PF_Passcode")
                print("PatientScreen LogoutAction end")
        }
    }

    /**
     Showing the view for Faq document.
     
     - parameter sender: faq button from inteface.
     */
    @IBAction func faqAction(sender: AnyObject) {
        print("PatientScreen faqAction begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "Faq", value: nil)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let faqWebView = storyBoard.instantiateViewControllerWithIdentifier("PFWebView") as! PFWebView
        faqWebView.url = NSURL(string: faqURL)
        faqWebView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(faqWebView, animated: true, completion: nil)
        print("PatientScreen faqAction end")
    }
    /**
     Showing the alert from the top and automatically close after 2 seconds.
     */

    func showUploadStatusAlert() {
        var uploadframe: CGRect!
        uploadframe=uploadStatusView.frame
        uploadframe.origin.x=self.view.frame.origin.x
        uploadframe.size.width=self.view.frame.size.width
        uploadframe.size.height=100
        uploadframe.origin.y=self.view.frame.origin.y-50
        self.uploadStatusView.frame=uploadframe
        self.view.addSubview(uploadStatusView)
        var setresize: CGRect!
        setresize=self.uploadStatusView.frame
        setresize.origin.x=self.uploadStatusView.frame.origin.x
        setresize.origin.y=0
        setresize.size.width=self.view.frame.size.width
        setresize.size.height=100
        UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.uploadStatusView.frame=setresize
            }, completion: nil)
        var setresizenormal: CGRect!
        setresizenormal=self.uploadStatusView.frame
        setresizenormal.origin.x=self.uploadStatusView.frame.origin.x
        setresizenormal.origin.y=0-self.uploadStatusView.frame.size.height
        setresizenormal.size.width=self.view.frame.size.width
        setresizenormal.size.height=100
        UIView.animateWithDuration(0.30, delay: 5.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.uploadStatusView.frame=setresizenormal
            }, completion: nil)
    }

    /**
     Refresh the access token by sending the already stored access token to the server.
     */
    func getRefreshToken() {
        print("PatientScreen getRefreshToken begin")
        PFGlobalConstants.sendEventWithCatogory("background", action: "functionCall", label: "refreshToken", value: nil)
        let defaults = NSUserDefaults.standardUserDefaults()
        let refresh_token = defaults.stringForKey("refresh_token")! as String
        requestString = "\(baseURL)/login"
        print(requestString)
        let clientID = "102216378240-rf6fjt3konig2fr3p1376gq4jrooqcdm"
        let clientSecret = "bYQU1LQAjaSQ1BH9j3zr7woO"
        url1 = NSURL(string: requestString as String)!
        urlRequest = NSMutableURLRequest(URL: url1)
        urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        self.patientModel?.loadvaluesParam(clientID, client_secret: clientSecret, refresh_token: refresh_token, grant_type: "refresh_token")
        Alamofire.request(urlRequest)
            .responseJSON { response in
                switch response.result {
                case .Failure( let error):
                    print(error)
                case .Success(let responseObject):
                    print(responseObject)
                    let response = responseObject as! NSDictionary
                    self.access_token = response.objectForKey("access_token")! as! String
                    self.token_type = response.objectForKey("token_type")! as! String
                    let refresh_token = response.objectForKey("refresh_token")! as! String
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject (self.access_token, forKey: "access_token")
                    defaults.setObject(self.token_type, forKey: "token_type")
                    defaults.setObject(refresh_token, forKey: "refresh_token")
                    self.loadvalues()
                }
                print("PatientScreen getRefreshToken end")
        }
    }

    @IBAction func docScanSwitcAction(sender: SevenSwitch) {
        print("PatientScreen docScanSwitcAction begin")
        let defaults = NSUserDefaults.standardUserDefaults()
        if docScanSwitch.isOn()
        {
            defaults.setBool(true, forKey: "isDocScanOn")
            defaults.synchronize()
            print("isDocScanOn switched On")
        }
        else
        {
            defaults.setBool(false, forKey: "isDocScanOn")
            defaults.synchronize()
            print("isDocScanOn switched On")
        }
        print("PatientScreen docScanSwitcAction end")
    }
    @IBAction func setPasscodeAction(sender: AnyObject) {
        
        print("PatientScreen setPasscodeAction begin")
        let defaults = NSUserDefaults.standardUserDefaults()
        if let passcode = defaults.objectForKey("PF_Passcode") as? String
        {
            thePin = passcode
            if !unlocked
            {
                let lockScreen = ABPadLockScreenViewController(delegate: self, complexPin: false)
                lockScreen.setAllowedAttempts(3)
                lockScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                lockScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                presentViewController(lockScreen, animated: true, completion: nil)
            }
            else
            {
                let lockSetupScreen = ABPadLockScreenSetupViewController(delegate: self, complexPin: false, subtitleLabelText: "Select a pin")
                lockSetupScreen.tapSoundEnabled = true
                lockSetupScreen.errorVibrateEnabled = true
                lockSetupScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                lockSetupScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                presentViewController(lockSetupScreen, animated: true, completion: nil)
            }
        }
        else {
            let lockSetupScreen = ABPadLockScreenSetupViewController(delegate: self, complexPin: false, subtitleLabelText: "Select a pin")
            lockSetupScreen.tapSoundEnabled = true
            lockSetupScreen.errorVibrateEnabled = true
            lockSetupScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            lockSetupScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            presentViewController(lockSetupScreen, animated: true, completion: nil)
        }
        print("PatientScreen setPasscodeAction end")
    }
    
    @IBAction func sendReport(sender: AnyObject) {
        print("PatientScreen sendReport begin")
        if( MFMailComposeViewController.canSendMail() ) {
            print("Can send email.")
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("Appliction log report")
            mailComposer.setMessageBody("", isHTML: false)
            
            var paths: Array = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documentsDirectory: String = paths[0]
            let logPath: String = documentsDirectory.stringByAppendingString("/console.log")
            if NSFileManager.defaultManager().fileExistsAtPath(logPath) {
                if let fileData = NSData(contentsOfFile: logPath) {
                    print("File data loaded.")
                    mailComposer.addAttachmentData(fileData, mimeType: "text/x-log", fileName: "console")
                }
            }
//            if let filePath = NSBundle.mainBundle().pathForResource("console", ofType: "log") {
//                print("File path loaded.")
//                
//                if let fileData = NSData(contentsOfFile: filePath) {
//                    print("File data loaded.")
//                    mailComposer.addAttachmentData(fileData, mimeType: "text/x-log", fileName: "console")
//                }
//            }
            self.presentViewController(mailComposer, animated: true, completion: nil)
            print("PatientScreen sendReport begin")
        }
        else
        {
            print("Email accounts not configured.")
            print("PatientScreen sendReport begin")
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Lock Screen Setup Delegate
    func pinSet(pin: String!, padLockScreenSetupViewController padLockScreenViewController: ABPadLockScreenSetupViewController!) {
        thePin = pin
        NSUserDefaults.standardUserDefaults().setObject(pin, forKey: "PF_Passcode")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func unlockWasCancelledForSetupViewController(padLockScreenViewController: ABPadLockScreenAbstractViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Lock Screen Delegate
    func padLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!, validatePin pin: String!) -> Bool {
        print("Validating Pin \(pin)")
        return thePin == pin
    }
    
    func unlockWasSuccessfulForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Successful!")
        pinUnlockTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector(PFSinginViewController.resetUnlockFlag), userInfo: nil, repeats: true)
        unlocked = true;
        dismissViewControllerAnimated(true, completion: nil)
        let lockSetupScreen = ABPadLockScreenSetupViewController(delegate: self, complexPin: false, subtitleLabelText: "Select a pin")
        lockSetupScreen.tapSoundEnabled = true
        lockSetupScreen.errorVibrateEnabled = true
        lockSetupScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        lockSetupScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        presentViewController(lockSetupScreen, animated: true, completion: nil)
    }
    
    func unlockWasUnsuccessful(falsePin: String!, afterAttemptNumber attemptNumber: Int, padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Failed Attempt \(attemptNumber) with incorrect pin \(falsePin)")
        if attemptNumber == 3
        {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func unlockWasCancelledForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Cancled")
        dismissViewControllerAnimated(true, completion: nil)
    }
    func resetUnlockFlag() {
        unlocked = false
    }
    
}

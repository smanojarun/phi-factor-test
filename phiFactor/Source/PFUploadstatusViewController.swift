//
//  PFUploadstatusViewController.swift
//  PhiFactor
//
//  Created by Apple on 30/05/16.
//  Copyright © 2016 Hubino. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

/// Showing the details about uploaded video as list.
@objc class PFUploadstatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var allVideoUpload: UIButton!
    @IBOutlet weak var uploadtable: UITableView!
    @IBOutlet var completedTableView: UITableView!
    @IBOutlet var customSectionHeaderInprogress: UIView!
    @IBOutlet var customSectionHeaderComplete: UIView!

    var patientId : NSMutableArray!
    var global: PFCameraScreenModel?
    var defults = NSUserDefaults.standardUserDefaults()
    var senderTag: Int!
    var patient = NSArray()
    var Status = NSMutableArray()
    var  progressview: UIView!

    @IBOutlet var nodataLabelInprogeress: UILabel!
    @IBOutlet var noDataLabel: UILabel!

    override func viewDidLoad() {

        super.viewDidLoad()
        nodataLabelInprogeress.hidden=true
        noDataLabel.hidden=true
        Status = ["InProgress", "Completed"]
        global = PFCameraScreenModel()

        getPatientVideoStatus()

        if((defults.objectForKey("patient") as? NSMutableArray) != nil) {
        patientId = (defults.objectForKey("patient") as? NSMutableArray)!
        print(patientId)
        }

        // Do any additional setup after loading the view.
    }

    /**
     GetPatientVideoStatus : Using Rest Service Get The Uploaded Media Status

     URL Format : baseURL/get_patient_video_status?Authorization=token_type&access_token=access_token
     Alamofire : For Web Service Calling
     */

    func getPatientVideoStatus()  {
        self.progessbar(self.view)
        self.progessbarshow()
        let defaults = NSUserDefaults.standardUserDefaults()
        var access_token:String!
        var token_type:String!
        access_token = defaults.stringForKey("access_token")
        token_type = defaults.stringForKey("token_type")
        print(access_token)
        print(token_type)
        let seconds2 = 0.79
        let delay2 = seconds2 * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime2 = dispatch_time(DISPATCH_TIME_NOW, Int64(delay2))
        dispatch_after(dispatchTime2, dispatch_get_main_queue(), {
        requestString = "\(baseURL)/get_patient_video_status?Authorization=\(token_type)&access_token=\(access_token)";
            
        url1 = NSURL(string: requestString as String)!;
        urlRequest = NSMutableURLRequest(URL: url1);
        urlRequest.HTTPMethod = Alamofire.Method.GET.rawValue;
            
        Alamofire.request(urlRequest)
            .responseJSON { response in
                switch response.result {
                case .Failure( let error):
                    print(error)
                case .Success(let responseObject):
                    print(responseObject)

                    let response = responseObject as! NSDictionary
                    print(response)
                    self.patient = response.objectForKey("patients") as! NSArray
                    PFUploadStatusModel.getpatientVideoStatusResponse(self.patient)
                    
                    if(self.patient.count==0) {
                        self.nodataLabelInprogeress.hidden=false
                        self.noDataLabel.hidden=false

                    }
                    else {
                    self.uploadtable.reloadData()
                    self.completedTableView.reloadData()
                    }
                    self.progressbarhidden()
                }
        }
        })
    }

    /**
    Used to navigate the current screen to previous view
     - parameter sender: Button sets in the interface
     */

    @IBAction func uploadBack(sender:AnyObject){
                 uploadSuccessfullyArr.removeAllObjects()
                inprogressArr.removeAllObjects()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PFSinginViewController") as! PFSinginViewController
        nextViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.dismissViewControllerAnimated(true) {
        }
    }

    /**
     Used to upload all file in the tableview

     - parameter sender: Button sets in the interface
     */

    @IBAction func allVideoUpload(sender: AnyObject) {

        allVideoUpload.tag=2
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PFUploadstatusViewController.videoStatus),
                                                         name: "videoStatus1",
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PFUploadstatusViewController.videoStatusTwo),
                                                         name: "videoStatus2",
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PFUploadstatusViewController.videoStatusThree),
                                                         name: "videoStatus3",
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PFUploadstatusViewController.videoStatusFour),
                                                         name: "videoStatus4",
                                                         object: nil)
        let uploadModel = PFUploadStatusModel()
        uploadModel.uploadAllFiles()
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PFUploadstatusViewController.uploadSuccess),
                                                         name: "UploadStatus",
                                                         object: nil)
    }

    /**
     Updating the video staus for the first video after video upload completed.

     - parameter notification: notification from the NSNotificationCenter
     */

    func videoStatus(notification: NSNotification){
        videoStatus1 = "completed"
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(videoStatus1, forKey: "completedVideoStatus1")
        let urlString = notification.userInfo!["videoUrl"] as! NSURL
        let url: String = urlString.absoluteString
        print(url)
        completed_video_update_status(videoStatus1, url: url)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "videoStatus1", object: nil)

    }

    /**
     Updating the video staus for the Second video after video upload completed.

     - parameter notification: notification from the NSNotificationCenter
     */

    func videoStatusTwo(notification: NSNotification){
        videoStatus2 = "completed"
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(videoStatus2, forKey: "completedVideoStatus2")
        let urlString = notification.userInfo!["videoUrl"] as! NSURL
        let url: String = urlString.absoluteString
        print(url)
        completed_video_update_status(videoStatus2, url: url)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "videoStatus2", object: nil)
    }

    /**
     Updating the video staus for the third video after video upload completed.

     - parameter notification: notification from the NSNotificationCenter
     */

    func videoStatusThree(notification: NSNotification){
        videoStatus3 = "completed"
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(videoStatus3, forKey: "completedVideoStatus3")
        let urlString = notification.userInfo!["videoUrl"] as! NSURL
        let url: String = urlString.absoluteString
        print(url)
        completed_video_update_status(videoStatus3, url: url)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "videoStatus3", object: nil)
    }

    /**
     Updating the video staus for the Fourth video after video upload completed.

     - parameter notification: notification from the NSNotificationCenter
     */

    func videoStatusFour(notification: NSNotification){
        videoStatus4 = "completed"
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(videoStatus4, forKey:"completedVideoStatus4")
        let urlString = notification.userInfo!["videoUrl"] as! NSURL
        let url: String = urlString.absoluteString
        print(url)
        completed_video_update_status(videoStatus4,url: url)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"videoStatus4", object:nil)
    }
    
    /**
     Updating the media status on the server.

     - parameter videoStatus: videoStatus to be updated.
     - parameter url:         videoStatus updated on the given url.
     */
    
    func completed_video_update_status(videoStatus:String!,url:AnyObject!)  {
        global = PFCameraScreenModel()
        let defaults = NSUserDefaults.standardUserDefaults()
        var access_token: String!
        var token_type: String!
        access_token = defaults.stringForKey("access_token")
        token_type = defaults.stringForKey("token_type")
        requestString = "\(baseURL)/update_media_status?Authorization=\(token_type)&access_token=\(access_token)"
        url1 = NSURL(string: requestString as String)!
        urlRequest = NSMutableURLRequest(URL: url1)
        urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        global?.update_media_status(videoStatus, url: url)
        Alamofire.request(urlRequest)
            .responseJSON { response in
                
                switch response.result {
                case .Failure( let error):
                    print(error)
                case .Success(let responseObject):
                    print(responseObject)
                    
                }
        }
        videoStatus2 = nil
        videoStatus3 = nil
        videoStatus4 = nil
        videoStatus1 = nil

        defaults.setObject(videoStatus1, forKey: "completedVideoStatus1")
        defaults.setObject(videoStatus2, forKey: "completedVideoStatus2")
        defaults.setObject(videoStatus3, forKey: "completedVideoStatus3")
        defaults.setObject(videoStatus4, forKey: "completedVideoStatus4")

    }

    /**
     Post notification function called from AWSBackgroundupload when the file uploaded successfully
     */

    func uploadSuccess()  {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"UploadStatus", object:nil)

        if(allVideoUpload.tag==2){
            uploadtable.reloadData()

        }
        else {
        let sender =   (defults.objectForKey("tag") as? Int)
        let indexPath = NSIndexPath(forRow:sender!,inSection: 0)
        let cell = uploadtable.cellForRowAtIndexPath(indexPath) as! PFUploadTableViewCell
        cell.uploadStatus.text="completed"

        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 90.0
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(tableView==uploadtable) {
            return customSectionHeaderInprogress
        }
        else {
            return customSectionHeaderComplete
        }
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView==uploadtable) {
            return  inprogressArr.count
        }
        else if(tableView==completedTableView) {
            return uploadSuccessfullyArr.count
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.uploadtable.dequeueReusableCellWithIdentifier("upload")! as! PFUploadTableViewCell
        if(tableView==uploadtable && inprogressArr.count != 0){
          let obj = inprogressArr[indexPath.row]
                let videoStatus = obj
                let delimiter = "-"
                var seprator = videoStatus.componentsSeparatedByString(delimiter)
                let patientId = seprator[0]
                let videoName = seprator[1]
            cell.patientIdLabel.text = patientId
            cell.videoStatusLabel.text = videoName
            if(indexPath.row % 2==0) {
                cell.backgroundColor=UIColor .clearColor()
            }
            else {
                cell.backgroundColor=UIColor .whiteColor()
            }

        }
         if(tableView==completedTableView && uploadSuccessfullyArr.count != 0){
            let obj = uploadSuccessfullyArr[indexPath.row]
                let videoStatus = obj
                let delimiter = "-"
                var seprator = videoStatus.componentsSeparatedByString(delimiter)
                let patientId = seprator[0]
                let videoName = seprator[1]
                cell.patientIdLabel.text = patientId
                cell.videoStatusLabel.text = videoName
            if(indexPath.row % 2==0) {
                cell.backgroundColor=UIColor .clearColor()
            }
            else {
                cell.backgroundColor=UIColor .whiteColor()
            }

        }
        if(inprogressArr==0) {
            self.nodataLabelInprogeress.hidden=false
        }
        else {
            self.nodataLabelInprogeress.hidden=true
        }
        if(uploadSuccessfullyArr==0) {
            self.noDataLabel.hidden=false
        }
        else {
            self.noDataLabel.hidden=true
        }
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     Dismisss the current view and showing the previousview.

     - parameter sender: back button from interface.
     */
    @IBAction func backtohome(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /**
     Adding the progress bar as subview to the given passview.
     
     - parameter passview: A view which should be a UIView.
     */

    func progessbar(passview: UIView) {
        var baseviewframe: CGRect!
        baseviewframe=passview.frame
        progressview=UIView(frame: baseviewframe)
        let progressviewimage=UIView(frame: CGRectMake((progressview.frame.size.width/2)-16, (progressview.frame.size.height/2-16), 32, 32))
        var progressviewimagegif: UIImageView!
        let imageData = NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("loading", withExtension: "gif")!)
        let advTimeGif = UIImage.gifWithData(imageData!)
        progressviewimagegif = UIImageView(image: advTimeGif)
        progressviewimagegif.frame.size.width=progressviewimage.frame.size.width
        progressviewimagegif.frame.size.height=progressviewimage.frame.size.height
        progressviewimage.addSubview(progressviewimagegif)
        progressview.backgroundColor=UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.2)
        progressview.addSubview(progressviewimage)
        self.view.addSubview(progressview)
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

}

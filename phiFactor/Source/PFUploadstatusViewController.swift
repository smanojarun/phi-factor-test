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
@objc class PFUploadstatusViewController: GAITrackedViewController, UITableViewDelegate, UITableViewDataSource,AppInactiveDelegate {

    @IBOutlet weak var calendarView: UIView!
    
    @IBOutlet var statusButton: UIButton!
   
    @IBOutlet weak var statusView: UIView!
    @IBOutlet var searchDateAlert: UIView!
    @IBOutlet  var startDateCalendar:FSCalendar!
    @IBOutlet var endDatecalendar: FSCalendar!
    @IBOutlet var datePicker: UIButton!
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet var allVideoUpload: UIButton!
    @IBOutlet weak var uploadtable: UITableView!
    @IBOutlet weak var inprogressButton: UIButton!
    @IBOutlet var completedTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet var customSectionHeaderInprogress: UIView!
    @IBOutlet var customSectionHeaderComplete: UIView!

    @IBOutlet weak var calendarSearchButton: UIButton!
    var patientId : NSMutableArray!
    var global: PFCameraScreenModel?
    var defults = NSUserDefaults.standardUserDefaults()
    var senderTag: Int!
    var patient = NSArray()
    var Status = NSMutableArray()
    var  progressview: UIView!
    var  startDate:String!
    var endDate:String!
    var date=NSDate()
    var displayTableContents: Int!
    var isShowingAlert = false
    @IBOutlet var nodataLabelInprogeress: UILabel!
    @IBOutlet var noDataLabel: UILabel!

    @IBOutlet var alertMessageLabel: UILabel!
    override func viewDidLoad() {
        backButton.hidden = true

        displayTableContents = 0
        self.statusView.alpha = 0
        calendarView.hidden = true
        print("UploadStatus viewDidLoad begin")
        self.screenName = PFUploadstatusViewControllerScreenName
        super.viewDidLoad()
        nodataLabelInprogeress.hidden=true
        //noDataLabel.hidden=true
        Status = ["InProgress", "Completed"]
        global = PFCameraScreenModel()
        uploadtable.hidden = true
        

//        completedTableView.hidden = true
        getPatientVideoStatus()

        if((defults.objectForKey("patient") as? NSMutableArray) != nil) {
        patientId = (defults.objectForKey("patient") as? NSMutableArray)!
        print(patientId)
        }
        print("UploadStatus viewDidLoad end")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        APP_DELEGATE?.inactiveDelegate = self
    }
@IBAction func datePickerAction(sender:AnyObject){
    
    calendarView.hidden = false
    self.statusView.alpha = 0

    
    }
    
    @IBAction func statusButtonAction(sender:AnyObject){
        UIView.animateWithDuration(0.5, delay: 0.4, options: .CurveEaseOut, animations: {
            self.statusView.hidden = false
            self.statusView.alpha = 1
            }, completion: nil)
        calendarView.hidden = true

    }
    @IBAction func backButtonAction(sender:AnyObject){
        self.startDate = nil
        self.endDate = nil
        getPatientVideoStatus()
        self.uploadtable.hidden = false
        self.nodataLabelInprogeress.hidden=true
        self.calendarSearchButton.hidden = false
        backButton.hidden = true


    }
    @IBAction func completedButtonAction(sender:AnyObject){
        if(completedArr.count==0){
            self.nodataLabelInprogeress.hidden = false
            self.uploadtable.hidden = true
            self.statusView.hidden = true
            backButton.hidden = false

            self.calendarSearchButton.hidden = true
        }
        else{
            self.uploadtable.hidden = false
        self.statusView.hidden = true
        displayTableContents = 1
        self.uploadtable.reloadData()
        }
    }
    @IBAction func notAvailableAction(sender:AnyObject){
        if(notAvailableArr.count==0){
            self.nodataLabelInprogeress.hidden = false
            self.uploadtable.hidden = true
            self.statusView.hidden = true
            self.calendarSearchButton.hidden = true
            backButton.hidden = false

        }
        else{
        displayTableContents = 3
        self.uploadtable.hidden = false
        self.statusView.hidden = true
        self.uploadtable.reloadData()
        }
    }
    @IBAction func inprogressButtonAction(sender:AnyObject){
        if(inprogressArr.count==0){
            self.calendarSearchButton.hidden = true
            backButton.hidden = false

            self.nodataLabelInprogeress.hidden = false
            self.statusView.hidden = true
            self.uploadtable.hidden = true
            
        }
        else{
            self.uploadtable.hidden = false
            self.statusView.hidden = true
            displayTableContents = 2
            self.uploadtable.reloadData()

            
        }
            }


    @IBAction func calendarSearchAction(sender:AnyObject){
        if(startDate==nil || endDate==nil){
            self.alertMessageLabel.text = "Please select start date and end date to search"
            showUploadStatusAlert()
        }
        else{
        self.calendarSearchButton.hidden = true
        getPatientVideoStatus()
        calendarView.hidden = true
        backButton.hidden = false
        }
        
    }
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate!) {
        if(calendar.tag==1){
        NSLog("calendar did select date \(endDatecalendar.stringFromDate(date))")
        startDate = endDatecalendar.stringFromDate(date)
            
        }
        else{
            NSLog("calendar did select date \(endDatecalendar.stringFromDate(date))")
            endDate = endDatecalendar.stringFromDate(date)
        }
        if(endDate != nil){
            print(endDate)
        }
        if(startDate != nil){
            print(startDate)
 
        }

    }
    
    func showUploadStatusAlert() {
        if !self.isShowingAlert {
            var uploadframe: CGRect!
            uploadframe=searchDateAlert.frame
            uploadframe.origin.x=self.view.frame.origin.x
            uploadframe.size.width=self.view.frame.size.width
            uploadframe.size.height=100
            uploadframe.origin.y=self.view.frame.origin.y-50
            self.searchDateAlert.frame=uploadframe
            self.view.addSubview(searchDateAlert)
            var setresize: CGRect!
            setresize=self.searchDateAlert.frame
            setresize.origin.x=self.searchDateAlert.frame.origin.x
            setresize.origin.y=0
            setresize.size.width=self.view.frame.size.width
            setresize.size.height=100
            isShowingAlert = true
            UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.searchDateAlert.frame=setresize
                }, completion: nil)
            var setresizenormal: CGRect!
            setresizenormal=self.searchDateAlert.frame
            setresizenormal.origin.x=self.searchDateAlert.frame.origin.x
            setresizenormal.origin.y=0-self.searchDateAlert.frame.size.height
            setresizenormal.size.width=self.view.frame.size.width
            setresizenormal.size.height=100
            UIView.animateWithDuration(0.30, delay: 3.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.searchDateAlert.frame=setresizenormal
            }) { (completed) in
                self.isShowingAlert = false
            }
        }
        
    }

    
    
//    func calendar(endDatecalendar: FSCalendar, didSelectDate date: NSDate) {
//        NSLog("calendar did select date \(endDatecalendar.stringFromDate(date))")
//       startDate = endDatecalendar.stringFromDate(date)
//    
//    }
//    func calendar(startDateCalendar: FSCalendar, didSelectDate date: NSDate) {
//        NSLog("calendar did select date \(startDateCalendar.stringFromDate(date))")
//        startDate = startDateCalendar.stringFromDate(date)
//        
//    }
//
    
    /**
     GetPatientVideoStatus : Using Rest Service Get The Uploaded Media Status

     URL Format : baseURL/get_patient_video_status?Authorization=token_type&access_token=access_token
     Alamofire : For Web Service Calling
     */

    func getPatientVideoStatus()  {
        print("UploadStatus getPatientVideoStatus begin")
        displayTableContents = 0
        PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "getPatientVideoStatus", value: nil)
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
            if(self.startDate != nil && self.endDate != nil) {
        requestString = "\(baseURL)/get_patient_video_status?start_date=\(self.startDate)&end_date=\(self.endDate)&Authorization=\(token_type)&access_token=\(access_token)";
            }
            else{
                 requestString = "\(baseURL)/get_patient_video_status?Authorization=\(token_type)&access_token=\(access_token)";
            }
            
            url1 = NSURL(string: requestString as String)!;
        urlRequest = NSMutableURLRequest(URL: url1);
        urlRequest.HTTPMethod = Alamofire.Method.GET.rawValue;
            
        Alamofire.request(urlRequest)
            .responseJSON { response in
                switch response.result {
                case .Failure( let error):
                    print(error)
                    self.progressbarhidden()
                case .Success(let responseObject):
                    print(responseObject)

                    let response = responseObject as! NSDictionary
                    print(response)
                    if let responseArray = response.objectForKey("patients") as? NSArray {
                        self.patient = responseArray
                        PFUploadStatusModel.getpatientVideoStatusResponse(self.patient)
                        
                        if(self.patient.count==0) {
                            self.uploadtable.reloadData()
                            self.uploadtable.hidden = true
                            self.calendarSearchButton.hidden = true
                            self.nodataLabelInprogeress.hidden=false
                            //self.noDataLabel.hidden=false
                            
                        }
                        else {
                            self.uploadtable.hidden = false
                            //self.completedTableView.hidden = false
                            self.uploadtable.reloadData()
                            //self.completedTableView.reloadData()
                        }
                    }
                    else {
                        self.uploadtable.hidden = true
                        //self.completedTableView.hidden = false
                        self.calendarSearchButton.hidden = true
                        self.nodataLabelInprogeress.hidden = false
//                        self.uploadtable.reloadData()
                    }
                    
                    self.progressbarhidden()
                }
                print("UploadStatus getPatientVideoStatus end")
        }
        })
    }

    /**
    Used to navigate the current screen to previous view
     - parameter sender: Button sets in the interface
     */

    @IBAction func uploadBack(sender:AnyObject){
        print("UploadStatus uploadBack begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "backToPatientScreen", value: nil)
        uploadSuccessfullyArr.removeAllObjects()
        inprogressArr.removeAllObjects()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PFSinginViewController") as! PFSinginViewController
        nextViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.dismissViewControllerAnimated(true) {
        }
        print("UploadStatus uploadBack end")
    }

    /**
     Used to upload all file in the tableview

     - parameter sender: Button sets in the interface
     */

    @IBAction func allVideoUpload(sender: AnyObject) {
        print("UploadStatus allVideoUpload begin")
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
        print("UploadStatus allVideoUpload end")
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
        let url: String = urlString.absoluteString!
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
        let url: String = urlString.absoluteString!
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
        let url: String = urlString.absoluteString!
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
        let url: String = urlString.absoluteString!
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

        return 60.0
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
           return customSectionHeaderComplete
//        }
//        else {
//            return customSectionHeaderComplete
//        }
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        calendarView.hidden = true
        UIView.animateWithDuration(0.5, delay: 0.4, options: .CurveEaseOut, animations: {
            self.statusView.alpha = 0
            }, completion: nil)
    }
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(displayTableContents==0){
            return  uploadSuccessfullyArr.count
        }
        else if(displayTableContents==1){
            return completedArr.count
        }
        else if(displayTableContents==2){
            return inprogressArr.count
        }
        else if(displayTableContents==3){
            return notAvailableArr.count
        }
        

        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.uploadtable.dequeueReusableCellWithIdentifier("upload")! as! PFUploadTableViewCell
       
        if(uploadSuccessfullyArr.count != 0 && displayTableContents==0){
         let  obj = uploadSuccessfullyArr[indexPath.row]
            let videoStatus = obj
            let delimiter = "|"
            var seprator = videoStatus.componentsSeparatedByString(delimiter)
            let patientId = seprator[0]
            let videoDate = seprator[1]
            let Status = seprator[2]
            let videoName = seprator[3]
            let delimiterForDate = " "
            if(videoDate != "nil"){
                var dateTimeSeprator = videoDate.componentsSeparatedByString(delimiterForDate)
                let dateValue = dateTimeSeprator[0]
                let time = dateTimeSeprator[1]
                //                let dateFormatter = NSDateFormatter()
                //                dateFormatter.dateFormat = "dd-MM-yyyy"
                //            date = dateFormatter.dateFromString(dateValue)!
                //                print(date)
                //let dateString = dateFormatter.stringFromDate(date)
                cell.dateLabel.text = dateValue
            }
            else{
                cell.dateLabel.text = videoDate
            }
            cell.patientIdLabel.text = patientId
            cell.videoName.text = videoName
            cell.statusLabel.text = Status
            if(Status=="completed"){
                cell.statusIcon.image = UIImage(named: "complete_icon.png")

            }
            else{
                cell.statusIcon.image = UIImage(named: "inprogress_icon.png")

            }
        }
        else if(completedArr.count != 0 && displayTableContents==1){
          let  obj = completedArr[indexPath.row]
            let videoStatus = obj
            let delimiter = "|"
            var seprator = videoStatus.componentsSeparatedByString(delimiter)
            let patientId = seprator[0]
            let videoDate = seprator[1]
            let Status = seprator[2]
            let videoName = seprator[3]
            let delimiterForDate = " "
            if(videoDate != "nil"){
                var dateTimeSeprator = videoDate.componentsSeparatedByString(delimiterForDate)
                let dateValue = dateTimeSeprator[0]
                let time = dateTimeSeprator[1]
                //                let dateFormatter = NSDateFormatter()
                //                dateFormatter.dateFormat = "dd-MM-yyyy"
                //            date = dateFormatter.dateFromString(dateValue)!
                //                print(date)
                //let dateString = dateFormatter.stringFromDate(date)
                cell.dateLabel.text = dateValue
            }
            else{
                cell.dateLabel.text = videoDate
            }
            cell.patientIdLabel.text = patientId
            cell.videoName.text = videoName
            cell.statusLabel.text = Status
            cell.statusIcon.image = UIImage(named: "complete_icon.png")

        }
        else if(inprogressArr.count != 0 && displayTableContents==2){
          let  obj = inprogressArr[indexPath.row]
            let videoStatus = obj
            let delimiter = "|"
            var seprator = videoStatus.componentsSeparatedByString(delimiter)
            let patientId = seprator[0]
            let videoDate = seprator[1]
            let Status = seprator[2]
            let videoName = seprator[3]
            let delimiterForDate = " "
            if(videoDate != "nil"){
                var dateTimeSeprator = videoDate.componentsSeparatedByString(delimiterForDate)
                let dateValue = dateTimeSeprator[0]
                let time = dateTimeSeprator[1]
                //                let dateFormatter = NSDateFormatter()
                //                dateFormatter.dateFormat = "dd-MM-yyyy"
                //            date = dateFormatter.dateFromString(dateValue)!
                //                print(date)
                //let dateString = dateFormatter.stringFromDate(date)
                cell.dateLabel.text = dateValue
            }
            else{
                cell.dateLabel.text = videoDate
            }
            cell.patientIdLabel.text = patientId
            cell.videoName.text = videoName
            cell.statusLabel.text = Status
            cell.statusIcon.image = UIImage(named: "inprogress_icon.png")

        }
        else if(notAvailableArr.count != 0 && displayTableContents==3){
            let  obj = notAvailableArr[indexPath.row]
            let videoStatus = obj
            let delimiter = "|"
            var seprator = videoStatus.componentsSeparatedByString(delimiter)
            let patientId = seprator[0]
            let videoDate = seprator[1]
            let Status = seprator[2]
            let videoName = seprator[3]
            let delimiterForDate = " "
            if(videoDate != "nil"){
                var dateTimeSeprator = videoDate.componentsSeparatedByString(delimiterForDate)
                let dateValue = dateTimeSeprator[0]
                let time = dateTimeSeprator[1]
                //                let dateFormatter = NSDateFormatter()
                //                dateFormatter.dateFormat = "dd-MM-yyyy"
                //            date = dateFormatter.dateFromString(dateValue)!
                //                print(date)
                //let dateString = dateFormatter.stringFromDate(date)
                cell.dateLabel.text = dateValue
            }
            else{
                cell.dateLabel.text = videoDate
            }
            cell.patientIdLabel.text = patientId
            cell.videoName.text = videoName
            cell.statusLabel.text = Status
            cell.statusIcon.image = UIImage(named: "inprogress_icon.png")

        }
            
        else{
            self.nodataLabelInprogeress.hidden=false
        }
        
            
            if(indexPath.row % 2==0) {
                //cell.backgroundColor=UIColor(red:204.0, green: 204.0, blue: 204.0, alpha: 1.0)
                cell.backgroundColor = UIColor.clearColor()

            }
            else {
                cell.backgroundColor=UIColor.whiteColor()
            }

        
//         if(tableView==completedTableView && uploadSuccessfullyArr.count != 0){
//            let obj = uploadSuccessfullyArr[indexPath.row]
//                let videoStatus = obj
//                let delimiter = "-"
//                var seprator = videoStatus.componentsSeparatedByString(delimiter)
//                let patientId = seprator[0]
//                let videoName = seprator[1]
//                cell.patientIdLabel.text = patientId
//                cell.videoStatusLabel.text = videoName
//            if(indexPath.row % 2==0) {
//                cell.backgroundColor=UIColor .clearColor()
//            }
//            else {
//                cell.backgroundColor=UIColor .whiteColor()
//            }
//
//        }
//        if(inprogressArr.count==0 || up) {
//            self.nodataLabelInprogeress.hidden=false
//        }
//        else {
//            self.nodataLabelInprogeress.hidden=true
//        }
//        if(uploadSuccessfullyArr==0) {
//            self.noDataLabel.hidden=false
//        }
//        else {
//            self.noDataLabel.hidden=true
//        }
       // cell.backgroundColor=UIColor .clearColor()
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
    
    func remainingTime(time: String) {
        if !isShowingAlert {
            var uploadframe: CGRect!
            uploadframe=searchDateAlert.frame
            uploadframe.origin.x=self.view.frame.origin.x
            uploadframe.size.width=self.view.frame.size.width
            uploadframe.size.height=100
            uploadframe.origin.y=self.view.frame.origin.y-50
            self.searchDateAlert.frame=uploadframe
            self.view.addSubview(searchDateAlert)
            var setresize: CGRect!
            setresize=self.searchDateAlert.frame
            setresize.origin.x=self.searchDateAlert.frame.origin.x
            setresize.origin.y=0
            setresize.size.width=self.view.frame.size.width
            setresize.size.height=100
            isShowingAlert = true
            self.alertMessageLabel.text = time
            UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.searchDateAlert.frame=setresize
                }, completion: nil)
        }
        else {
            self.alertMessageLabel.text = time
        }
        
    }
    func hideInactiveAlert() {
        var setresizenormal: CGRect!
        setresizenormal=self.searchDateAlert.frame
        setresizenormal.origin.x=self.searchDateAlert.frame.origin.x
        setresizenormal.origin.y=0-self.searchDateAlert.frame.size.height
        setresizenormal.size.width=self.view.frame.size.width
        setresizenormal.size.height=100
        UIView.animateWithDuration(0.30, delay: 3.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.searchDateAlert.frame=setresizenormal
        }) { (completed) in
            self.isShowingAlert = false
        }
    }

}

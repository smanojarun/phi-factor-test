//
//  ResumePatientListViewController.swift
//  PhiFactor
//
//  Created by Shajakhan on 04/11/16.
//  Copyright © 2016 Hubino. All rights reserved.
//

import UIKit

class ResumePatientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var resumePatientsTable: UITableView!    
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    var patientsArray : NSArray!
    var selectedIndex = 0
    var userSelected = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.skipButton.addTarget(self, action: #selector(ResumePatientListViewController.skipAction(_:)), forControlEvents: .TouchUpInside)
        self.continueButton.addTarget(self, action: #selector(ResumePatientListViewController.resumeSessionAction(_:)), forControlEvents: .TouchUpInside)

        resumePatientsTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patientsArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.resumePatientsTable.dequeueReusableCellWithIdentifier("resumePatientCell")! as! ResumePatientDetailsCell
        cell.patientNameLabel.text = patientsArray[indexPath.row].objectForKey("patient_name") as? String
        cell.patientIDLabel.text = patientsArray[indexPath.row].objectForKey("patient_mrn_id") as? String
        if(indexPath.row % 2==0) {
            cell.backgroundColor = UIColor.clearColor()
        }
        else {
            cell.backgroundColor = UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1.0)
        }
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        userSelected = true
        selectedIndex = indexPath.row
    }
    @IBAction func skipAction(sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let patientsDetailsScreen = storyBoard.instantiateViewControllerWithIdentifier("PFSinginViewController") as! PFSinginViewController
        let nav = UINavigationController(rootViewController: patientsDetailsScreen)
        nav.navigationBarHidden = true
        let appDelegaet = UIApplication.sharedApplication().delegate as? AppDelegate
        UIView.transitionWithView((appDelegaet?.window)!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            appDelegaet!.window?.rootViewController = nav
        }) { (isCompleted) in
            self.view = nil
        }
    }
    @IBAction func resumeSessionAction(sender: UIButton) {
        if userSelected == true {
            dispatch_async(dispatch_get_main_queue(), { 
                NSUserDefaults.standardUserDefaults().setObject((self.patientsArray[self.selectedIndex].objectForKey("patient_id")), forKey: "patient_id")
                NSUserDefaults.standardUserDefaults().setObject((self.patientsArray[self.selectedIndex].objectForKey("patient_id")), forKey: PFPatientIDOnDB)
                PFGlobalConstants.setResumeVideoCount(Int((self.patientsArray[self.selectedIndex].objectForKey("resume_video"))! as! NSNumber))
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PFCameraviewcontrollerscreen") as! PFCameraviewcontrollerscreen
                nextViewController.isResumeCameraViewEnabled = true
                let nav = UINavigationController(rootViewController: nextViewController)
                nav.navigationBarHidden = true
                let appDelegaet = UIApplication.sharedApplication().delegate as? AppDelegate
                UIView.transitionWithView((appDelegaet?.window)!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    appDelegaet!.window?.rootViewController = nav
                }) { (isCompleted) in
                    self.view = nil
                }
            })
        }
    }
    
}

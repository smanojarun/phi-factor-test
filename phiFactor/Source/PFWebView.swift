//
//  PFWebView.swift
//  PhiFactor
//
//  Created by Apple on 20/07/16.
//  Copyright © 2016 Hubino. All rights reserved.
//

import UIKit

class PFWebView: GAITrackedViewController, UIWebViewDelegate, AppInactiveDelegate {

    var url : NSURL! = nil
    @IBOutlet var webView: UIWebView!
    @IBOutlet var activityImageView: UIImageView!
    @IBOutlet var alertView: UIView!
    @IBOutlet var alertMessageLabel: UILabel!
    var isShowingAlert = false
    override func viewDidLoad() {
        super.viewDidLoad()
        print("webView viewDidLoad begin")
        self.screenName = PFWebViewScreenName
        let imageData = NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("loading", withExtension: "gif")!)
        self.activityImageView.image = UIImage.gifWithData(imageData!)
        self.activityImageView.hidden = true
        // Do any additional setup after loading the view.
        if url != nil
        {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
        print("webView viewDidLoad end")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        APP_DELEGATE?.inactiveDelegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backButtonAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func webViewDidStartLoad(webView: UIWebView) {
        self.activityImageView.hidden = false
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        self.activityImageView.hidden = true
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.activityImageView.hidden = true
    }
    func remainingTime(time: String) {
        if !self.isShowingAlert {
            var alertViewFrame: CGRect!
            alertViewFrame=alertView.frame
            alertViewFrame.origin.x=self.view.frame.origin.x
            alertViewFrame.size.width=self.view.frame.size.width
            alertViewFrame.size.height=100
            alertViewFrame.origin.y=self.view.frame.origin.y-50
            self.alertView.frame=alertViewFrame
            self.view.addSubview(alertView)
            self.alertMessageLabel.text = time
            var setresize: CGRect!
            setresize=self.alertView.frame
            setresize.origin.x=self.alertView.frame.origin.x
            setresize.origin.y=0
            setresize.size.width=self.view.frame.size.width
            setresize.size.height=100
            isShowingAlert = true
            UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.alertView.frame=setresize
                }, completion: nil)
        }
        else {
            self.alertMessageLabel.text = time
        }
    }
    func hideInactiveAlert() {
        if isShowingAlert {
            var setresizenormal: CGRect!
            setresizenormal=self.alertView.frame
            setresizenormal.origin.x=self.alertView.frame.origin.x
            setresizenormal.origin.y=0-self.alertView.frame.size.height
            setresizenormal.size.width=self.view.frame.size.width
            setresizenormal.size.height=100
            UIView.animateWithDuration(0.30, delay: 3.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.alertView.frame=setresizenormal
            }) { (completed) in
                self.isShowingAlert = false
            }
        }
        
    }
}

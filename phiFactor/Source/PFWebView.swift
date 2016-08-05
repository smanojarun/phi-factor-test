//
//  PFWebView.swift
//  PhiFactor
//
//  Created by Apple on 20/07/16.
//  Copyright © 2016 Hubino. All rights reserved.
//

import UIKit

class PFWebView: GAITrackedViewController, UIWebViewDelegate {

    var url : NSURL! = nil
    @IBOutlet var webView: UIWebView!
    @IBOutlet var activityImageView: UIImageView!
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
}

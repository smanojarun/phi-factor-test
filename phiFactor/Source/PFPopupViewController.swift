
//
//  PFPopupViewController.swift
//  PhiFactor
//
//  Created by Apple on 21/05/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import UIKit
    extension UIButton{

        func setImage(image: UIImage?, inFrame frame: CGRect?, forState state: UIControlState){
            self.setImage(image, forState: state)

            if let frame = frame{
                self.imageEdgeInsets = UIEdgeInsets(
                    top: frame.minY - self.frame.minY,
                    left: frame.minX - self.frame.minX,
                    bottom: self.frame.maxY - frame.maxY,
                    right: self.frame.maxX - frame.maxX
                )
            }
        }

    }

class PFPopupViewController: UIViewController, UIPopoverPresentationControllerDelegate{
    var customSwitch: CustomSwitch!
    var  Previewswitch: CustomSwitch!
    var  onDemandswitch: Customswitch2!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor (red: 52/255, green: 52/255, blue: 52/255, alpha: 0.75)
        
        // Preview status
//        let Preview = UIButton()
//        Preview.setTitle("Preview", forState: .Normal)
//        Preview.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//        Preview.titleLabel!.font =  UIFont(name:"Calibri", size: 15)
//        
//        Preview.frame = CGRectMake(-19,4,120,30)
//        let Previewimage = UIImage(named:"PFSP_preview_icon.png")
//        Preview.setImage(
//            Previewimage,
//            inFrame: CGRectMake(8,10,18,15),
//            forState: UIControlState.Normal
//        )
        // Preview switch
       // Previewswitch = CustomSwitch()
//        Previewswitch.frame = CGRectMake(110.0,7, 20, 20)
//        Previewswitch.backgroundColor = UIColor.clearColor()
//        Previewswitch.layer.cornerRadius = 8.0
//        self.view.addSubview(Previewswitch)
        
        // seperator line 1
//                let seperatorline1 = UILabel()
//               seperatorline1.backgroundColor = UIColor (red: 46/255, green: 46/255, blue: 46/255, alpha: 0.70)
//               seperatorline1.frame = CGRectMake(0,35,150,1)
        let onDemand = UIButton()
        onDemand.setTitle("onDemand", forState: .Normal)
        onDemand.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        onDemand.titleLabel!.font =  UIFont(name:"Calibri", size: 15)
        
        onDemand.frame = CGRectMake(-11,10,120,30)
        let onDemandimage = UIImage(named:"PFSP_ondemand_icon.png")
        onDemand.setImage(
            onDemandimage,
            inFrame: CGRectMake(8,17,15,15),
            forState: UIControlState.Normal
        )
        // Ondemand switch
        onDemandswitch = Customswitch2()
        onDemandswitch.frame = CGRectMake(110.0,13, 20, 20)
        onDemandswitch.backgroundColor = UIColor.clearColor()
        onDemandswitch.layer.cornerRadius = 8.0
        self.view.addSubview(onDemandswitch)
        
        //seperatorline 2
        let seperatorline2 = UILabel()
        seperatorline2.backgroundColor = UIColor (red: 46/255, green: 46/255, blue: 46/255, alpha: 0.70)
        seperatorline2.frame = CGRectMake(0,45,150,1)
       
        
//        // upload button
//        let UploadStatus = UIButton()
//        UploadStatus.setTitle("Upload Status", forState: .Normal)
//        UploadStatus.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//        UploadStatus.titleLabel!.font =  UIFont(name:"Calibri", size: 15)
//        UploadStatus.frame = CGRectMake(0,73,120,30)
//        let image = UIImage(named:"PFSP_signout_image.png")
//        UploadStatus.setImage(
//            image,
//            inFrame: CGRectMake(8,79,15,15),
//            forState: UIControlState.Normal
//        )
//        UploadStatus.addTarget(self, action: #selector(PFPopupViewController.UploadStatusAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//
//
//        let seperatorline3 = UILabel()
//        seperatorline3.backgroundColor = UIColor (red: 46/255, green: 46/255, blue: 46/255, alpha: 0.70)
//        seperatorline3.frame = CGRectMake(0,105,150,1)

        // logout status
        let Logout = UIButton()
        Logout.setTitle("Logout", forState: .Normal)
        Logout.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        Logout.titleLabel!.font =  UIFont(name:"Calibri", size: 15)
        
        Logout.frame = CGRectMake(-21,50,120,30)
        let Logoutimage = UIImage(named:"PFSP_logout_image.png")
        Logout.setImage(
            Logoutimage,
            inFrame: CGRectMake(8,57,15,15),
            forState: UIControlState.Normal
        )
        Logout.addTarget(self, action: #selector(PFPopupViewController.LogoutAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
//        self.view .addSubview(Preview)
//        self.view .addSubview(seperatorline1)
        self.view .addSubview(onDemand)
        self.view .addSubview(seperatorline2)
//        self.view .addSubview(UploadStatus)
//        self.view .addSubview(seperatorline3)
        self.view .addSubview(Logout)
    }

     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func shouldAutorotate() -> Bool {
        
        return false
        
    }
    func UploadStatusAction(sender:UIButton!)
    {
        print("UploadStatusAction tapped")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PFUploadstatusViewController") as! PFUploadstatusViewController
        nextViewController.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
    func LogoutAction(sender:UIButton!)
    {
        print("LogoutAction tapped")
        let defaults = NSUserDefaults.standardUserDefaults()
        // defaults.setBool(true, forKey: "UseTouchID")
        defaults.setInteger(1, forKey: "logout")
        defaults.setObject ("" ,forKey:"access_token")
        defaults.setObject("",forKey:"token_type")
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PhiFactorIntro") as! PhiFactorIntro
        
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
}

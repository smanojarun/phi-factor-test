
//
//  PhiFactorIntro.swift
//  PhiFactor
//
//  Created by Apple on 18/05/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import DeviceKit
import Crashlytics

extension String {
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailTest  = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
}
extension UIView {
    /**
     Removes all constraints for this view
     */

    func removeConstraints() {
        if let superview = self.superview {
            var list = [NSLayoutConstraint]()
            for constraint in superview.constraints {
                if constraint.firstItem as? UIView == self || constraint.secondItem as? UIView == self {
                    list.append(constraint)
                }
            }
            superview.removeConstraints(list)
        }
        self.removeConstraints(self.constraints)
    }

}


class PhiFactorIntro: GAITrackedViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, ABPadLockScreenSetupViewControllerDelegate, ABPadLockScreenViewControllerDelegate {

    var logout: NSNumber!
    var warningmessage: String?
    var loginModel = PFLogingModel()
    var istextend: Bool!
    var cameraModel: PFCameraScreenModel?
    private(set) var thePin: String?

    @IBOutlet weak var playbackgroundview: UIView!
    @IBOutlet weak var baseviewforreferenceview: UIView!
    @IBOutlet weak var maillabel: UILabel!
    @IBOutlet weak var warninforpassword: UILabel!
    @IBOutlet weak var warning: UILabel!
    @IBOutlet weak var passwordlabel: UILabel!
    @IBOutlet weak var forgotpasslabel: UILabel!
    @IBOutlet weak var getStarted: UIButton!
    @IBOutlet weak var referview: UIView!
    @IBOutlet var signinview: UIView!
    @IBOutlet var baseview: UIView!
    @IBOutlet var forgotpassword: UIView!
    @IBOutlet weak var playbackview: UIView!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var emailID: UITextField!
    @IBOutlet var networkAlertView: UIView!
    @IBOutlet var netwrkAlertLabel: UILabel!
    @IBOutlet var forgotPasswordAlertView: UIView!
    @IBOutlet var forgotPasswordAlertLabel: UILabel!
    @IBOutlet var restPasswordButton: UIButton!
    @IBOutlet var reEnterPasswordTextField: UITextField!
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var currentPasswordTextField: UITextField!
    @IBOutlet var resetToLoginButton: UIButton!
    @IBOutlet var restPasswordView: UIView!
    @IBOutlet var restPasswordSuccessLabel: UILabel!
    @IBOutlet var email_idwarning: UIButton!
    @IBOutlet var labelAppVersion: UILabel!
    @IBOutlet var resumeSessionAlertView: UIView!
    @IBOutlet var resumeAlertLabel: UILabel!
    
    var uuidValue:String!
    var  progressview: UIView!
    var avPlayer1 = AVPlayer()
    var avPlayerLayer1: AVPlayerLayer!
    var access_token: String!
    var token_type: String!
    var blurEffectView = UIView()
    var isFromLogout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("IntroScreen viewDidLoad begin")
        self.screenName = PhiFactorIntroScreenName
        if let version : String = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        {
            if let bundle_version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String
            {
                labelAppVersion.text = String("V \(version).\(bundle_version)")
            }
        }
//        let versionInt : Int = (NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? Int)!
        cameraModel = PFCameraScreenModel()
        loginModel=PFLogingModel()
        //      default hidden
        getStarted.hidden=true
        self.getStarted.enabled=true
        self.username.delegate=self

        self.password.delegate=self
        self.emailID.delegate=self
        self.emailID.keyboardType = UIKeyboardType.EmailAddress
         self.username.keyboardType = UIKeyboardType.EmailAddress
        istextend=true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PhiFactorIntro.keyboardWillShow(_: )), name: UIKeyboardWillShowNotification, object: nil)
        let defaults = NSUserDefaults.standardUserDefaults()
        let notoplay: NSNumber!
        notoplay = defaults.integerForKey("notoplay")
        logout = defaults.integerForKey("logout")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willEnterForeground), name: "KSDIdlingWindowActiveNotification", object: nil)
        if(notoplay==1) {
            getStarted.hidden=false
            self.baseview.insertSubview(playbackgroundview, atIndex: 0)
            referview.hidden=false
            cameraModel!.avPlayerLayer = AVPlayerLayer(player: cameraModel!.avPlayer)
            self.playbackgroundview.layer.insertSublayer(cameraModel!.avPlayerLayer, atIndex: 0)
            let path2 = NSBundle.mainBundle().pathForResource("splash_bg1", ofType: "mp4")
            let url = NSURL.fileURLWithPath(path2!)
            let playerItem = AVPlayerItem(URL: url)
            cameraModel!.avPlayer.replaceCurrentItemWithPlayerItem(playerItem)
            cameraModel!.avPlayer.play()
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: #selector(PhiFactorIntro.restartgifVideoFromBeginning),
                                                             name: AVPlayerItemDidPlayToEndTimeNotification,
                                                             object: cameraModel!.avPlayer.currentItem)
            cameraModel!.avPlayerLayer.frame = self.baseview.bounds
            self.baseview.addSubview(baseviewforreferenceview)
            self.baseviewforreferenceview.addSubview(getStarted)
            baseviewforreferenceview.hidden=false
        }
        else {

            self.baseview.addSubview(playbackgroundview)
            self.baseview.insertSubview(playbackgroundview, atIndex: 0)
            referview.hidden=false
            avPlayerLayer1 = AVPlayerLayer(player: avPlayer1)
            self.playbackgroundview.layer.insertSublayer(avPlayerLayer1, atIndex: 0)
            let path = NSBundle.mainBundle().pathForResource("splash_bg1", ofType: "mp4")
            let url2 = NSURL.fileURLWithPath(path!)
            let playerItem2 = AVPlayerItem(URL: url2)
            avPlayer1.replaceCurrentItemWithPlayerItem(playerItem2)
            avPlayer1.play()
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: #selector(PhiFactorIntro.restartgifVideoFromBeginning),
                                                             name: AVPlayerItemDidPlayToEndTimeNotification,
                                                             object: avPlayer1.currentItem)
             playbackgroundview.hidden=true
            referview.hidden=true
            avPlayerLayer1.frame = self.baseview.bounds
            self.baseview.addSubview(playbackview)
            cameraModel!.avPlayerLayer = AVPlayerLayer(player: cameraModel!.avPlayer)
            self.playbackview.layer.insertSublayer(cameraModel!.avPlayerLayer, atIndex: 1)
            let path2 = NSBundle.mainBundle().pathForResource("splash_intro", ofType: "mp4")
            let url = NSURL.fileURLWithPath(path2!)
            let playerItem = AVPlayerItem(URL: url)
            cameraModel!.avPlayer.replaceCurrentItemWithPlayerItem(playerItem)
            cameraModel!.avPlayer.play()
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PhiFactorIntro.restartVideoFromBeginning),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: cameraModel!.avPlayer.currentItem)

            cameraModel!.avPlayerLayer.frame = self.baseview.bounds
            getStarted.hidden=true

        }
        print(logout)
        if(logout==1) {

            playbackgroundview.hidden=false
            baseviewforreferenceview.hidden=false
            referview.translatesAutoresizingMaskIntoConstraints = false
            var playbackframe: CGRect!
            playbackframe = self.referview.frame
            playbackframe.origin.x = 0
            playbackframe.origin.y=self.baseview.frame.size.height-(self.referview.frame.size.height+250)
            playbackframe.size.width=self.referview.frame.size.width
            playbackframe.size.height=self.referview.frame.size.height
            self.referview.frame=playbackframe
            baseviewforreferenceview .addSubview(self.referview)

            NSLayoutConstraint(item: referview, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0).active = true
            NSLayoutConstraint(item: referview, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: -100).active = true

           self.baseviewforreferenceview.addSubview(self.referview)

            var setframe: CGRect!
            setframe=self.baseview.frame
            setframe.origin.x=self.baseview.frame.origin.x
            setframe.origin.y=self.baseview.frame.size.height
            setframe.size.width=self.baseview.frame.size.width
            setframe.size.height=self.signinview.frame.size.height

            self.signinview.frame=setframe

            var setfinalframe: CGRect!
            setfinalframe=self.signinview.frame
            setfinalframe.origin.x=self.signinview.frame.origin.x
            setfinalframe.origin.y=self.baseview.frame.size.height-self.signinview.frame.size.height
            setfinalframe.size.width=self.baseview.frame.size.width
            setfinalframe.size.height=self.signinview.frame.size.height
            self.signinview.frame=setfinalframe
            self.baseview.addSubview(self.signinview)
            self.progessbar(self.signinview)
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(0, forKey: "logout")

        }
        else {
            print("logout is no")
        }
//        let defaults = NSUserDefaults.standardUserDefaults()
//        user = defaults.objectForKey(PF_USERNAME) as? String
//        pass = defaults.objectForKey(PF_PASSWORD) as? String
//        if user != nil && pass != nil
//        {
//            self.registerDeviceService(false)
//        }
        if isFromLogout {
            self.getStarted.hidden = true
        }
        print("IntroScreen viewDidLoad end")
    }
    
    /**
     Restart the get started screen background video from beggining after reach the end of the video.
     */
    
    func restartVideoFromBeginning() {
        UIView.transitionWithView((playbackview)!, duration: 0.30, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.playbackview.hidden=true
        }) { (isCompleted) in
        }

        
        UIView.transitionWithView((playbackgroundview)!, duration: 0.10, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
           
            self.playbackgroundview.hidden=false

        }) { (isCompleted) in
        }
        referview.hidden=false
        getStarted.hidden=false
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "UseTouchID")
        defaults.setInteger(0, forKey: "nottopaly")
    }

    /**
     Restart the get started screen background video from beggining after reach the end of the video.
     */
    func restartgifVideoFromBeginning() {
        let seconds: Int64 = 0
        let preferredTimeScale: Int32 = 1
        let seekTime: CMTime = CMTimeMake(seconds, preferredTimeScale)
        let notoplay: NSNumber!
        let defaults = NSUserDefaults.standardUserDefaults()
        notoplay = defaults.integerForKey("notoplay")

        if(notoplay==1) {
            cameraModel!.avPlayer.seekToTime(seekTime)
            cameraModel!.avPlayer.play()
            avPlayer1.play()
        }
        else {
            avPlayer1.seekToTime(seekTime)
            avPlayer1.play()
        }

    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraModel!.avPlayer.play()
        avPlayer1.play()
    }
    override func viewDidAppear(animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /**
     Animating the current view to display subview to sign in.
 
     - parameter sender: getStarted button from interface.
     */
    @IBAction func getStarted(sender: AnyObject) {

        print("IntroScreen getStarted begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "GetStarted", value: nil)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(1, forKey: "notoplay")
        getStarted.hidden=true

        var setframe: CGRect!
        setframe=self.baseview.frame
        setframe.origin.x=self.baseview.frame.origin.x
        setframe.origin.y=self.baseview.frame.size.height
        setframe.size.width=self.baseview.frame.size.width
        setframe.size.height=self.signinview.frame.size.height

        self.signinview.frame=setframe

        var setfinalframe: CGRect!
        setfinalframe=self.signinview.frame
        setfinalframe.origin.x=self.signinview.frame.origin.x
        setfinalframe.origin.y=self.baseview.frame.size.height-self.signinview.frame.size.height
        setfinalframe.size.width=self.baseview.frame.size.width
        setfinalframe.size.height=self.signinview.frame.size.height


        var playbackframe: CGRect!
        playbackframe = self.referview.frame
        playbackframe.origin.x = 0
        playbackframe.origin.y=self.baseview.frame.size.height-(self.referview.frame.size.height+250)
        playbackframe.size.width=self.referview.frame.size.width
        playbackframe.size.height=self.baseview.frame.size.height

        UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
            self.referview.frame=playbackframe
        }, completion: nil)
        maillabel.layer.cornerRadius = 13
        maillabel.clipsToBounds=true

        passwordlabel.layer.cornerRadius = 13
        passwordlabel.clipsToBounds=true

        forgotpasslabel.layer.cornerRadius = 13
        forgotpasslabel.clipsToBounds=true

        let seconds = 0.39
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.signinview.frame=setfinalframe
                    self.baseview.addSubview(self.signinview)
                }, completion: nil)
        })

        let seconds2 = 0.79
        let delay2 = seconds2 * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime2 = dispatch_time(DISPATCH_TIME_NOW, Int64(delay2))
        dispatch_after(dispatchTime2, dispatch_get_main_queue(), {

            var setfinalframe2: CGRect!
            setfinalframe2=self.signinview.frame
            setfinalframe2.origin.x=self.signinview.frame.origin.x
            setfinalframe2.origin.y=self.signinview.frame.origin.y+5
            setfinalframe2.size.width=self.baseview.frame.size.width
            setfinalframe2.size.height=self.signinview.frame.size.height

            UIView.animateWithDuration(0.10,
                delay: 0.0,
                usingSpringWithDamping: 10.0,
                initialSpringVelocity: 0.10,
                options: UIViewAnimationOptions.TransitionFlipFromBottom,
                animations: {
                    self.signinview.frame=setfinalframe2
                }, completion: nil)
             self.progessbar(self.signinview)
        })
        print("IntroScreen getStarted end")
    }

    /**
     Checking the device compatiblity and if its true proceed to the signin credetials.
     Otherwise show the alert with message Device not compatible.
     - parameter sender: signin button from interface.
     */
    
    @IBAction func signin(sender: AnyObject) {
        print("IntroScreen signin begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "SignIn", value: nil)
        self.warning.text = ""
        getStarted.hidden=true

        let device = Device()
        if istextend ==  false {
            self.baseview.frame.origin.y += 200
            istextend = true
            self.username.resignFirstResponder()
            self.password.resignFirstResponder()
        }
        if(!PFGlobalConstants().isDeviceCompatibile()) {

            UIAlertView(title: "", message: "The device doesn't meet the minimum requirements to run the application.", delegate: nil, cancelButtonTitle: "OK").show()
            print("DeviceNotMeetMinReq")
            PFGlobalConstants.sendException("DeviceNotMeetMinReq", isFatal: false)
        }
        else {

            if(self.username.text=="") {
                self.username.attributedPlaceholder = NSAttributedString(string: "Enter username",
                                                                         attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
//                self.password.attributedPlaceholder = NSAttributedString(string: "Enter password",
//                                                                         attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
//                self.password.shake(4, withDelta: 5)
                self.username.shake(4, withDelta: 5)

            }
            else if(self.username.text=="") {
                self.username.attributedPlaceholder = NSAttributedString(string: "Enter username",
                                                                         attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
                self.username.shake(4, withDelta: 5)

            }
//            else if(self.password.text=="") {
//                self.password.attributedPlaceholder = NSAttributedString(string: "Enter password",
//                                                                         attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
//                self.password.shake(4, withDelta: 5)
//
//            }
             else {
                user=username.text!
                pass=password.text!

                if(!(user == nil)) {
                    if(!user.isEmail) {
                        self.password.attributedPlaceholder = NSAttributedString(string: "Enter valid password",
                                                                                 attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])


                        self.warning.text="Enter valid username"
                        self.warning.textColor = UIColor.redColor()
                        self.warning.font = UIFont(name: "calibri", size: CGFloat(13))
                        self.warning.hidden=false
                        self.username.shake(4, withDelta: 5)
                    }
                     else {

                        registerDeviceService(true)
//                        self.userLoginService()
                    }
                }
            }
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject (warningmessage, forKey: "Warning")
        }
        print("IntroScreen signin end")
    }

    /**
     Animating the current view to display subview to forget password action.

     - parameter sender: forget password button from interface.
     */

    @IBAction func forgotpasswor(sender: AnyObject) {
        print("IntroScreen forgotpasswor begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "ForgotPassword", value: nil)
        getStarted.hidden=true

        if istextend ==  false {
            self.baseview.frame.origin.y += 200
            istextend = true
            self.username.resignFirstResponder()
            self.password.resignFirstResponder()
            self.reEnterPasswordTextField.resignFirstResponder()
            self.newPasswordTextField.resignFirstResponder()
            self.currentPasswordTextField.resignFirstResponder()
        }
        var setframepass: CGRect!
        setframepass=self.forgotpassword.frame
        setframepass.origin.x=self.baseview.frame.origin.x
        setframepass.origin.y=self.baseview.frame.size.height
        setframepass.size.width=self.baseview.frame.size.width
        setframepass.size.height=self.forgotpassword.frame.size.height
        self.forgotpassword.frame=setframepass
        var setfinalframepass: CGRect!
        setfinalframepass=self.forgotpassword.frame
        setfinalframepass.origin.x=self.forgotpassword.frame.origin.x
        setfinalframepass.origin.y=self.baseview.frame.size.height-self.signinview.frame.size.height
        setfinalframepass.size.width=self.forgotpassword.frame.size.width
        setfinalframepass.size.height=self.forgotpassword.frame.size.height
         var setsigninreduce: CGRect!
        setsigninreduce=self.signinview.frame
        setsigninreduce.origin.x=self.signinview.frame.origin.x
        setsigninreduce.origin.y=self.baseview.frame.size.height+20
        setsigninreduce.size.width=self.baseview.frame.size.width
        setsigninreduce.size.height=self.forgotpassword.frame.size.height
        UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.signinview.frame=setsigninreduce
            }, completion: nil)
        UIView.animateWithDuration(0.40, delay: 0.39, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.forgotpassword.frame=setfinalframepass
                self.baseview.addSubview(self.forgotpassword)
            }, completion: nil)
        var setfinalframepass2: CGRect!
        setfinalframepass2=self.forgotpassword.frame
        setfinalframepass2.origin.x=self.forgotpassword.frame.origin.x
        setfinalframepass2.origin.y=self.forgotpassword.frame.origin.y+5
        setfinalframepass2.size.width=self.baseview.frame.size.width
        setfinalframepass2.size.height=self.forgotpassword.frame.size.height
        UIView.animateWithDuration(0.40, delay: 0.79, usingSpringWithDamping: 10.0,initialSpringVelocity: 0.10,
            options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                self.forgotpassword.frame=setfinalframepass2
                 self.progessbar(self.forgotpassword)
            }, completion: nil)
        print("IntroScreen forgotpasswor end")
    }

    /**
     Animating and shows the forget password subview to login subview

     - parameter sender: back to login button from interface.
     */

    @IBAction func backtologin(sender: AnyObject)
    {
        print("IntroScreen backtologin begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "BackToLogin", value: nil)
        if istextend ==  false {
            self.baseview.frame.origin.y += 200
            istextend = true
            self.emailID.resignFirstResponder()
        }
        self.restPasswordSuccessLabel.text = ""
        self.currentPasswordTextField.text = ""
        self.newPasswordTextField.text = ""
        self.reEnterPasswordTextField.text = ""
        
        if(resetToLoginButton.tag==1){
            
            var restPasswordResize:CGRect!
            restPasswordResize=self.restPasswordView.frame
            restPasswordResize.origin.x=self.restPasswordView.frame.origin.x;
            restPasswordResize.origin.y=self.baseview.frame.size.height+20;
            restPasswordResize.size.width=self.baseview.frame.size.width
            restPasswordResize.size.height=self.restPasswordView.frame.size.height;
            var setframepass:CGRect!
            setframepass=self.signinview.frame;
            setframepass.origin.x=self.baseview.frame.origin.x;
            setframepass.origin.y=self.baseview.frame.size.height;
            setframepass.size.width=self.baseview.frame.size.width
            setframepass.size.height=self.signinview.frame.size.height;
            
            UIView.animateWithDuration(0.40, delay:0, options:UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.restPasswordView.frame=restPasswordResize;
                    
                }, completion:nil)
            
            UIView.animateWithDuration(0.40, delay:0.39, options:UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.signinview.frame=setframepass;
                }, completion:nil)
            
            self.progressbarhidden()
            
        }
     
        self.warninforpassword.hidden=true
        var setframepass:CGRect!
        setframepass=self.forgotpassword.frame;
        setframepass.origin.x=self.baseview.frame.origin.x;
        setframepass.origin.y=self.baseview.frame.size.height+200;
        setframepass.size.width=self.baseview.frame.size.width
        setframepass.size.height=self.forgotpassword.frame.size.height;
        
        var setresize:CGRect!
        setresize=self.signinview.frame
        setresize.origin.x=self.forgotpassword.frame.origin.x;
        setresize.origin.y=self.baseview.frame.size.height-self.signinview.frame.size.height+5;
        setresize.size.width=self.baseview.frame.size.width
        setresize.size.height=self.signinview.frame.size.height;
        
        UIView.animateWithDuration(0.40, delay:0, options:UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                self.forgotpassword.frame=setframepass;
                
            }, completion:nil)
        
        UIView.animateWithDuration(0.40, delay:0.39, options:UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                self.signinview.frame=setresize;
            }, completion:nil)
        print("IntroScreen backtologin end")
    }

    /**
     Requesting the password reset by sending the email ID entered by user.
     If email id is valid proceed to the password reset progress.
     Otherwise shows the error alert.

     - parameter sender: Send it Now button from interface.
     */

    @IBAction func PFIsenditnow(sender: AnyObject) {
        print("IntroScreen PFIsenditnow begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "SendItNow", value: nil)
        if istextend ==  false {
            self.baseview.frame.origin.y += 200
            istextend = true
            self.emailID.resignFirstResponder()
            self.reEnterPasswordTextField.resignFirstResponder()
            self.newPasswordTextField.resignFirstResponder()
            self.currentPasswordTextField.resignFirstResponder()
        }
        if(self.emailID.text=="") {
            self.emailID.attributedPlaceholder = NSAttributedString(string: "Enter email id",
                                                                      attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
        }
        else {
            let email = emailID.text
            if(!(email!.isEmail)) {
                self.emailID.attributedPlaceholder = NSAttributedString(string: "Enter email id", attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
                self.warninforpassword.text="Enter valid email id"
                self.warninforpassword.textColor = UIColor.redColor()
                self.warninforpassword.font = UIFont(name: "calibri", size: CGFloat(18))
                self.warninforpassword.hidden=false
            }
            else {
                self.progessbarshow()
                let requestString: NSString = "\(baseURL)/forgot_password"

                let url1: NSURL = NSURL(string: requestString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
                urlRequest = NSMutableURLRequest(URL: url1)
                urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
                let parameters1 = ["user_email_id": email!]
                do {
                    urlRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters1, options: NSJSONWritingOptions())
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    // No-op
                }
                Alamofire.request(urlRequest)
                    .responseJSON { response in
                        switch response.result {
                        case .Failure( let error):
                            let err = error as NSError
                            if err.code == -1009 {
                                self.netwrkAlertLabel.text = networkErrorAlertText
                                self.networkAlertViewAction()
                            }
                             else {
                                self.netwrkAlertLabel.text = "There is an error occured."
                                self.networkAlertViewAction()
                            }
                            print("Network erroer")
                            PFGlobalConstants.sendException("NetworkError", isFatal: false)
                            self.progressbarhidden()
                        case .Success(let responseObject):
                            print(responseObject)
                            let responseDict = responseObject as? NSDictionary
                            if response.response?.statusCode == 401
                            {
                                self.emailID.attributedPlaceholder = NSAttributedString(string: "Enter email id",   attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
                                if let message = responseDict?.objectForKey("message") as? String
                                {
                                    self.warninforpassword.text = message
                                }
                                else
                                {
                                    self.warninforpassword.text = "Enter valid email id"
                                }
                                
                                self.warninforpassword.textColor = UIColor.redColor()
                                self.warninforpassword.font = UIFont(name: "calibri", size: CGFloat(18))
                                self.warninforpassword.hidden=false
                                self.progressbarhidden()
                            }
                            else {
                                self.emailID.text=""
                                self.warninforpassword.text = "Email send successfully, Please check your inbox!"
                                self.warninforpassword.textColor = UIColor.orangeColor()
                                self.emailID.attributedPlaceholder = NSAttributedString(string: "Email",   attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])

                                self.warninforpassword.hidden=false
                                self.progressbarhidden()
                            }
                        }
                        print("IntroScreen PFIsenditnow end")
                }
            }
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject (warningmessage, forKey: "Warning")
    }
    
    /**
     Displaying the video uplaod status alert to the user after complition of four video recordings.
     */
    
    func showUploadStatusAlert() {
        var uploadframe: CGRect!
        uploadframe=forgotPasswordAlertView.frame
        uploadframe.origin.x=self.view.frame.origin.x
        uploadframe.size.width=self.view.frame.size.width
        uploadframe.size.height=100
        uploadframe.origin.y=self.view.frame.origin.y-50
        self.forgotPasswordAlertView.frame=uploadframe
        self.view.addSubview(forgotPasswordAlertView)
        var setresize: CGRect!
        setresize=self.forgotPasswordAlertView.frame
        setresize.origin.x=self.forgotPasswordAlertView.frame.origin.x
        setresize.origin.y=0
        setresize.size.width=self.view.frame.size.width
        setresize.size.height=100
        UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.forgotPasswordAlertView.frame=setresize
            }, completion: nil)
        var setresizenormal: CGRect!
        setresizenormal=self.forgotPasswordAlertView.frame
        setresizenormal.origin.x=self.forgotPasswordAlertView.frame.origin.x
        setresizenormal.origin.y=0-self.forgotPasswordAlertView.frame.size.height
        setresizenormal.size.width=self.view.frame.size.width
        setresizenormal.size.height=100
        UIView.animateWithDuration(0.30, delay: 5.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.forgotPasswordAlertView.frame=setresizenormal
            }, completion: nil)
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        print("Start")
        switch textField {
        case username:
            textField.attributedPlaceholder = NSAttributedString(string:"Youremail@domain.com",
                                                                                     attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
            break
        case password:
            textField.attributedPlaceholder = NSAttributedString(string:"Password",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
            break
        case emailID:
            textField.attributedPlaceholder = NSAttributedString(string:"Email",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
            break
        case currentPasswordTextField:
            textField.attributedPlaceholder = NSAttributedString(string:"Current Password",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
            break
        case newPasswordTextField:
            textField.attributedPlaceholder = NSAttributedString(string:"New Password",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
            break
        case reEnterPasswordTextField:
            textField.attributedPlaceholder = NSAttributedString(string:"Re-Enter New Password",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
            break
            
        default:
            break
        }
        
        if(textField.tag==11) {
            self.warning.text = ""
        }
        else if(textField.tag==12) {
            self.warning.text = ""
        }
        else if(textField.tag==13) {
            self.warninforpassword.hidden=true
        }
    }

    func textFieldDidEndEditing(textField: UITextField) {
    }

    func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()) != nil {
        if(istextend==true) {
            self.baseview.frame.origin.y =  self.baseview.frame.origin.y-200
             }
           istextend=false
         }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == UIReturnKeyType.Next
        {
            password.becomeFirstResponder()
        }
        else if textField.returnKeyType == UIReturnKeyType.Go
        {
            textField.resignFirstResponder()
            istextend=true
            self.baseview.frame.origin.y += 200
            self.view.endEditing(true)
            signin(self)
        }
        else
        {
            textField.resignFirstResponder()
            istextend=true
            self.baseview.frame.origin.y += 200
            self.view.endEditing(true)
        }
        currentPasswordTextField.resignFirstResponder()
        newPasswordTextField.resignFirstResponder()
        reEnterPasswordTextField.resignFirstResponder()
        
        return true
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if(textField.text==self.username.text) {

        }
        else if(textField.text==self.password.text) {

        }
        return true
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
        progressview.hidden=true
    }

    /**
     progress bar create and set it to unhidden
     */

    func progessbarshow() {
        if progressview != nil {
            progressview.hidden=false
        }
    }

    /**
     progress bar create and set it to hidden
     */

    func progressbarhidden() {
        if progressview != nil {
            progressview.hidden=true
        }
    }

    /**
     Showing the alert for the user to no network available.
     */
    
    func networkAlertViewAction() {
        var uploadframe: CGRect!
        uploadframe=networkAlertView.frame
        uploadframe.origin.x=self.view.frame.origin.x
        uploadframe.size.width=self.view.frame.size.width
        uploadframe.size.height=110
        uploadframe.origin.y=self.view.frame.origin.y-110
        self.networkAlertView.frame=uploadframe
        self.view.addSubview(networkAlertView)
        var setresize: CGRect!
        setresize=self.networkAlertView.frame
        setresize.origin.x=self.networkAlertView.frame.origin.x
        setresize.origin.y=0
        setresize.size.width=self.view.frame.size.width
        setresize.size.height=110
        UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.networkAlertView.frame=setresize
            }, completion: nil)
    }

    /**
     Close the network alert view by the user.
     */
    
    @IBAction func closeNerworkAlert() {
        var setresizenormal: CGRect!
        setresizenormal=self.networkAlertView.frame
        setresizenormal.origin.x=self.networkAlertView.frame.origin.x
        setresizenormal.origin.y=0-self.networkAlertView.frame.size.height
        setresizenormal.size.width=self.view.frame.size.width
        setresizenormal.size.height=110
        UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.networkAlertView.frame=setresizenormal
            }, completion: nil)
    }
    
    /**
     Validate the the entered password and also check the new and reEnter password field having same text. After that request the server to change the password.
     
     - parameter sender: reset password button from inteface.
     */
    @IBAction func restPasswordAction(sender: AnyObject){
        print("IntroScreen restPasswordAction begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "ResetPassword", value: nil)
        self.progessbarshow()
        restPasswordSuccessLabel.hidden=false
        let pattern = "(?=^.{8,}$)(?=.*[!@#$%^&*]+)(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$"
        let regex = try! NSRegularExpression(pattern:pattern , options: [.AnchorsMatchLines])
        let newPassResult = regex.firstMatchInString(self.newPasswordTextField.text!, options:[], range: NSMakeRange(0, self.newPasswordTextField.text!.characters.count))
        let reEnterPassResult = regex.firstMatchInString(self.reEnterPasswordTextField.text!, options:[], range: NSMakeRange(0, self.reEnterPasswordTextField.text!.characters.count))
        if(currentPasswordTextField.text==""){
            self.currentPasswordTextField.attributedPlaceholder = NSAttributedString(string:"Enter current password",
                                                                                     attributes:[NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
            self.currentPasswordTextField.shake(4, withDelta: 5)
        }
        if(newPasswordTextField.text==""){
            self.newPasswordTextField.attributedPlaceholder = NSAttributedString(string:"Enter new password",
                                                                                 attributes:[NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
            self.newPasswordTextField.shake(4, withDelta: 5)
        }
        if(reEnterPasswordTextField.text==""){
            self.reEnterPasswordTextField.attributedPlaceholder = NSAttributedString(string:"Re-Enter new password",
                                                                                     attributes:[NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
            self.reEnterPasswordTextField.shake(4, withDelta: 5)
        }
        else if (reEnterPassResult == nil || newPassResult == nil)
        {
            self.restPasswordSuccessLabel.text = "Password should contains minimum 8 characters and one uppercase character and one lowercase character"
        }
        else{
            let currentPassword = currentPasswordTextField.text
            let newPassword = newPasswordTextField.text
            let reEnterPassword = reEnterPasswordTextField.text
            
            if(newPassword==reEnterPassword){
                requestString = "\(baseURL)/reset_password"
                print(requestString)
                url1 = NSURL(string: requestString as String)!;
                
                urlRequest = NSMutableURLRequest(URL: url1);
                urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue;
                loginModel.resetPasswordParam(currentPassword!, new: newPassword!, uuid: uuidValue)
                
                Alamofire.request(urlRequest)
                    
                    .responseJSON { response in
                        
                        switch response.result {
                        case .Failure( let error):
                            print(error)
                            let err = error as NSError
                            if err.code == -1009 {
                                self.netwrkAlertLabel.text = networkErrorAlertText
                                self.networkAlertViewAction()
                            }
                            else {
                                self.netwrkAlertLabel.text = "There is an error occured."
                                self.networkAlertViewAction()
                            }
                            PFGlobalConstants.sendException("NetworkError", isFatal: false)
                        case .Success(let responseObject):
                            print(responseObject)
                            
                            let httpStatusCode = response.response?.statusCode
                            if(httpStatusCode==401){
                                self.restPasswordSuccessLabel.text = "New password does not match previous 5 passwords"
                            }
                            else if(httpStatusCode==400){
                                self.restPasswordSuccessLabel.text = "Invalid Old Passwords"
                            }
                            else if(httpStatusCode==200){
                                self.warning.text = "Password Changed Successfully."
                                self.currentPasswordTextField.text = ""
                                self.newPasswordTextField.text = ""
                                self.reEnterPasswordTextField.text = ""
                                var setframepass: CGRect!
                                setframepass=self.restPasswordView.frame
                                setframepass.origin.x=self.baseview.frame.origin.x
                                setframepass.origin.y=self.baseview.frame.size.height+20
                                setframepass.size.width=self.baseview.frame.size.width
                                setframepass.size.height=self.restPasswordView.frame.size.height
                                var setresize: CGRect!
                                setresize=self.signinview.frame
                                setresize.origin.x=self.restPasswordView.frame.origin.x
                                setresize.origin.y=self.baseview.frame.size.height-self.signinview.frame.size.height
                                setresize.size.width=self.baseview.frame.size.width
                                setresize.size.height=self.signinview.frame.size.height
                                UIView.animateWithDuration(0.40, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                                    self.restPasswordView.frame=setframepass
                                    }, completion: nil)
                                
                                UIView.animateWithDuration(0.40, delay: 0.39, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                                    self.signinview.frame=setresize
                                    }, completion: nil)

                            }
                            self.progressbarhidden()
                        }
                        print("IntroScreen restPasswordAction end")
                }
            }
            else{
                self.restPasswordSuccessLabel.text = "New Password Doesn't Match With Your Re-Enter Password"
                print("IntroScreen restPasswordAction end")
            }
        }
    }

    /**
     *  Function called when enter forground.
     */
    
    func willEnterForeground() {
        // do stuff
        cameraModel!.avPlayer.play()
        avPlayer1.play()
    }
    
    func userLoginService() {
        print("IntroScreen userLoginService begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "UserLoginService", value: nil)
        self.progessbarshow()
        requestString = "\(baseURL)/login_dup"
        print(requestString)
        url1 = NSURL(string: requestString as String)!
        
        urlRequest = NSMutableURLRequest(URL: url1)
        urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        loginModel.param(user, pass: pass, grandType: "password", url: urlRequest)
        
        
        Alamofire.request(urlRequest)
            
            .responseJSON { response in
                
                switch response.result {
                case .Failure( let error):
                    let err = error as NSError
                    if err.code == -1009 {
                        self.netwrkAlertLabel.text = networkErrorAlertText
                        self.networkAlertViewAction()
                    }
                    else {
                        self.netwrkAlertLabel.text = "There is an error occured."
                        self.networkAlertViewAction()
                    }
                    print("Network error")
                    self.progressbarhidden()
                case .Success(let responseObject):
                    print(responseObject)
                    
                    let httpStatusCode = response.response?.statusCode
                    print(httpStatusCode)
                    
                    if(httpStatusCode==200) {
                        Crashlytics.sharedInstance().setUserEmail(user)
                        let response = responseObject as! NSDictionary
                        let access_token = response.objectForKey("access_token")! as! String
                        let token_type = response.objectForKey("token_type")! as! String
                        let refresh_token = response.objectForKey("refresh_token")! as! String
                        self.access_token = access_token
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setObject (access_token ,forKey: "access_token")
                        defaults.setObject(token_type, forKey: "token_type")
                        defaults.setObject(refresh_token, forKey: "refresh_token")
                        defaults.setObject(user, forKey: PF_USERNAME)
                        defaults.setObject(pass, forKey: PF_PASSWORD)
//                        let patientIDOnDB = defaults.integerForKey(PF_PatientIDOnDB)
//                        if  patientIDOnDB != 0{
//                            self.getPatientDetails(patientIDOnDB)
//                        }
//                        else {
//                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PFSinginViewController") as! PFSinginViewController
//                            let nav = UINavigationController(rootViewController: nextViewController)
//                            nav.navigationBarHidden = true
//                            let appDelegaet = UIApplication.sharedApplication().delegate as? AppDelegate
//                            UIView.transitionWithView((appDelegaet?.window)!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
//                                appDelegaet!.window?.rootViewController = nav
//                            }) { (isCompleted) in
//                                self.view = nil
//                            }
//                        }
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PFSinginViewController") as! PFSinginViewController
                        let nav = UINavigationController(rootViewController: nextViewController)
                        nav.navigationBarHidden = true
                        let appDelegaet = UIApplication.sharedApplication().delegate as? AppDelegate
                        UIView.transitionWithView((appDelegaet?.window)!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                            appDelegaet!.window?.rootViewController = nav
                        }) { (isCompleted) in
                            self.view = nil
                        }
                        
                    }
                    else if(httpStatusCode==400) {
                        print("Invalid params")
                        let responseDict = responseObject as? NSDictionary
                        
                        self.username.attributedPlaceholder = NSAttributedString(string: "Enter valid username",
                            attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
                        
                        self.password.attributedPlaceholder = NSAttributedString(string: "Enter valid password",
                            attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
                        if let message = responseDict?.objectForKey("error_description") as? String
                        {
                            self.warning.text = message
                        }
                        else
                        {
                            self.warning.text = "Enter valid username and password"
                        }
                        self.warning.textColor = UIColor.redColor()
                        
                        self.warning.font = UIFont(name: "calibri", size: CGFloat(13))
                        self.warning.hidden=false
                        self.password.shake(4, withDelta: 5)
                        self.username.shake(4, withDelta: 5)
                        
                        
                        self.progressbarhidden()
                    }
                    else if(httpStatusCode==401) {
                        print("unauthorised")
                        let responseDict = responseObject as? NSDictionary
                        
                        self.username.attributedPlaceholder = NSAttributedString(string: "Enter valid username",
                            attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
                        
                        self.password.attributedPlaceholder = NSAttributedString(string: "Enter valid password",
                            attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "calibri", size: 18.0)! ])
                        
                        if let message = responseDict?.objectForKey("error_description") as? String
                        {
                            self.warning.text = message
                        }
                        else
                        {
                            self.warning.text = "Enter valid username and password"
                        }
                        self.warning.textColor = UIColor.redColor()
                        
                        self.warning.font = UIFont(name: "calibri", size: CGFloat(13))
                        self.warning.hidden=false
                        
                        self.password.shake(4, withDelta: 5)
                        self.username.shake(4, withDelta: 5)
                        self.progressbarhidden()
                    }
                    else if(httpStatusCode==505){
                        
                        let response = responseObject as! NSDictionary
                        self.uuidValue = response.objectForKey("uuid")! as! String
                        
                        self.baseview.addSubview(self.restPasswordView)
                        var restPasswordResize:CGRect!
                        restPasswordResize=self.restPasswordView.frame
                        restPasswordResize.origin.x=self.restPasswordView.frame.origin.x;
                        restPasswordResize.origin.y=self.baseview.frame.size.height;                                        restPasswordResize.size.width=self.baseview.frame.size.width
                        restPasswordResize.size.height=self.restPasswordView.frame.size.height;
                        self.restPasswordView.frame=restPasswordResize
                        
                        var setframepass:CGRect!
                        setframepass=self.signinview.frame;
                        setframepass.origin.x=self.baseview.frame.origin.x;
                        setframepass.origin.y=self.baseview.frame.size.height;
                        setframepass.size.width=self.baseview.frame.size.width
                        setframepass.size.height=self.signinview.frame.size.height;
                        
                        var setresize:CGRect!
                        setresize=self.restPasswordView.frame
                        setresize.origin.x=self.restPasswordView.frame.origin.x;
                        setresize.origin.y=self.baseview.frame.size.height-250;
                        setresize.size.width=self.baseview.frame.size.width
                        setresize.size.height=self.restPasswordView.frame.size.height+250;
                        
                        UIView.animateWithDuration(0.40, delay:0, options:UIViewAnimationOptions.CurveEaseInOut, animations:
                            {
                                self.signinview.frame=setframepass;
                                
                            }, completion:nil)
                        UIView.animateWithDuration(0.40, delay:0.39, options:UIViewAnimationOptions.CurveEaseInOut, animations:
                            {
                                self.restPasswordView.frame=setresize;
                            }, completion:nil)
                    }
                }
                print("IntroScreen userLoginService end")
        }
    }
    
    func registerDeviceService(isFromSignInButton: Bool) {
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "RegisterDevice", value: nil)
        self.progessbarshow()
        let registerDeviceUrlString = "\(baseURL)/register_device"
        let registerDeviceURl = NSURL(string: registerDeviceUrlString)
        urlRequest = NSMutableURLRequest(URL: registerDeviceURl!)
        urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        urlRequest = loginModel.getRegisterDeviceParams(user)
        Alamofire.request(urlRequest).responseJSON { (response) in
            switch response.result
            {
            case .Failure(let error):
                let err = error as NSError
                if err.code == -1009 {
                    self.netwrkAlertLabel.text = networkErrorAlertText
                    self.networkAlertViewAction()
                }
                else {
                    self.netwrkAlertLabel.text = "There is an error occured."
                    self.networkAlertViewAction()
                }
                self.progressbarhidden()
                break
            case .Success(let responseObject):
                let httpStatusCode = response.response?.statusCode
                print(httpStatusCode)
                print(responseObject)
                if(httpStatusCode==200) {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    if let passcode = defaults.objectForKey("PF_Passcode") as? String {
                        self.thePin = passcode
                        PFGlobalConstants.authenticateUserByTouchID({ (status) in
                            switch status{
                            case .authorized:
                                let response = responseObject as! NSDictionary
                                let result = response.objectForKey("result")! as! String
                                let message = response.objectForKey("message")! as! String
                                if result == "Success"
                                {
                                    self.userLoginService()
                                    self.warning.text = ""
                                    self.warning.textColor = UIColor.lightGrayColor()
                                }
                                else
                                {
                                    self.warning.text = message
                                    self.warning.textColor = UIColor.redColor()
                                }
                                break
                            case .unAuthorized:
                                self.warning.text = "Touch ID authentication failed."
                                self.warning.textColor = UIColor.redColor()
                                dispatch_async(dispatch_get_main_queue(), {
                                    if(PFGlobalConstants.isPasscodeAvailable()) {
                                        let lockScreen = ABPadLockScreenViewController(delegate: self, complexPin: false)
                                        lockScreen.setAllowedAttempts(3)
                                        lockScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                                        lockScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                                        isAuthorizationRequesting = true;
                                        self.presentViewController(lockScreen, animated: true, completion: nil)
                                    }
                                    else
                                    {
                                        UIAlertView(title: "", message: "No registered passcode found.", delegate: nil, cancelButtonTitle: "Ok").show()
                                    }
                                })
                                break
                            case .unKnown:
                                self.warning.text = "Check touch id configured and enabled on your device to begin."
                                self.warning.textColor = UIColor.redColor()
                                break
                            case .canceled:
                                break
                            }
                        })
                    }
                    else
                    {
                        if isFromSignInButton
                        {
                            PFGlobalConstants.authenticateUserByTouchID({ (status) in
                                switch status{
                                case .authorized:
                                    let response = responseObject as! NSDictionary
                                    let result = response.objectForKey("result")! as! String
                                    let message = response.objectForKey("message")! as! String
                                    if result == "Success"
                                    {
                                        self.userLoginService()
                                        self.warning.text = ""
                                        self.warning.textColor = UIColor.lightGrayColor()
                                    }
                                    else
                                    {
                                        self.warning.text = message
                                        self.warning.textColor = UIColor.redColor()
                                    }
                                    break
                                case .unAuthorized:
                                    self.warning.text = "Touch ID authentication failed."
                                    self.warning.textColor = UIColor.redColor()
                                    dispatch_async(dispatch_get_main_queue(), {
                                        if(PFGlobalConstants.isPasscodeAvailable()) {
                                            let lockScreen = ABPadLockScreenViewController(delegate: self, complexPin: false)
                                            lockScreen.setAllowedAttempts(3)
                                            lockScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                                            lockScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                                            isAuthorizationRequesting = true;
                                            self.presentViewController(lockScreen, animated: true, completion: nil)
                                        }
                                        else
                                        {
                                            UIAlertView(title: "", message: "No registered passcode found.", delegate: nil, cancelButtonTitle: "Ok").show()
                                        }
                                    })
                                    break
                                case .unKnown:
                                    self.warning.text = "Check touch id configured and enabled on your device to begin."
                                    self.warning.textColor = UIColor.redColor()
                                    break
                                case .canceled:
                                    break
                                }
                            })
                        }
                    }
                }
                else if httpStatusCode == 201 {
                    let response = responseObject as! NSDictionary
                    let message = response.objectForKey("message")! as! String
                    self.warning.text = message
                    self.warning.textColor = UIColor.redColor()
                }
                else if httpStatusCode == 400 {
                    let response = responseObject as! NSDictionary
                    let message = response.objectForKey("message")! as! String
                    self.warning.text = message
                    self.warning.textColor = UIColor.redColor()
                }
                self.progressbarhidden()
                break
            }
        }
        
    }
    
    
    @IBAction func resumeSessionOKButtonAction(sender: AnyObject) {
        removeResumeSessionAlert()
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
    }
    @IBAction func resumeSessionCancelAction(sender: AnyObject) {
        removeResumeSessionAlert()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PFSinginViewController") as! PFSinginViewController
        let nav = UINavigationController(rootViewController: nextViewController)
        nav.navigationBarHidden = true
        let appDelegaet = UIApplication.sharedApplication().delegate as? AppDelegate
        UIView.transitionWithView((appDelegaet?.window)!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            appDelegaet!.window?.rootViewController = nav
        }) { (isCompleted) in
            self.view = nil
            NSUserDefaults.standardUserDefaults().removeObjectForKey(PF_PatientIDOnDB)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(PF_ResumeVideoCount)
        }
    }
    
    func  removeResumeSessionAlert() {
        var setresizenormal: CGRect!
        setresizenormal=self.resumeSessionAlertView.frame
        setresizenormal.origin.x=self.resumeSessionAlertView.frame.origin.x
        setresizenormal.origin.y=self.resumeSessionAlertView.frame.size.height
        setresizenormal.size.width=self.view.frame.size.width
        setresizenormal.size.height=self.resumeSessionAlertView.frame.size.height
        UIView.animateWithDuration(0.30, delay: 0, options: .CurveEaseInOut, animations: {
            self.resumeSessionAlertView.frame=setresizenormal
        }) { (completed) in
            self.blurEffectView.removeFromSuperview()
        }
    }
    
    /**
     Showing the confirmation alert from top while back button is pressed for exit the current session or not.
     */
    func showResumeSessionAlertView() {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        //        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        resumeSessionAlertView.frame.size.width=self.view.frame.size.width
        resumeSessionAlertView.frame.size.height=self.view.frame.size.height
        resumeSessionAlertView.frame.origin.x=0
        resumeSessionAlertView.frame.origin.y=self.view.frame.size.height
        self.view.addSubview(resumeSessionAlertView)
        var setframe=resumeSessionAlertView.frame
        setframe.size.width=resumeSessionAlertView.frame.size.width
        setframe.size.height=resumeSessionAlertView.frame.size.height
        setframe.origin.y=0
        setframe.origin.x=0
        UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.TransitionCurlUp, animations: {
            self.resumeSessionAlertView.frame=setframe
            }, completion: nil)
    }
    
    /**
     Loading inial data
     Service - Rest Service API
     For Web service Calling - Alamofire Framework used
     URL Format - "baseURL/load_initial_data?Authorization=token_type&access_token=access_token_value"
     */
    
    func getPatientDetails(patientID: Int) {
        print("PatientScreen getPatientDetails begin")
        self.progessbarshow()
        PFGlobalConstants.sendEventWithCatogory("background", action: "functionCall", label: "loadValues", value: nil)
        let app_version : Int = Int(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String)!
        requestString = "\(baseURL)/get_patient_details?Authorization=\(token_type)&access_token=\(access_token)&app_version=\(app_version)"
        print(requestString)
        url1 = NSURL(string: requestString as String)!
        urlRequest = NSMutableURLRequest(URL: url1)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let patientModel = PFPatientDetailsModel()
        patientModel.getPatientDetailsParameters(patientID)
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
                        PFGlobalConstants.logoutUser()
                    }
                    else {
                        self.netwrkAlertLabel.text = networkErrorAlertText
                        self.networkAlertViewAction()
                    }
                case .Success(let responseObject):
                    print(responseObject)
                    let httpStatusCode = response.response?.statusCode
                    print(httpStatusCode)
                    if(httpStatusCode==200) {
                        let response = responseObject as! NSDictionary
                        print(response)
                        if let patientName = response.objectForKey("Patient Name") as? String{
                            if let patientMrnId = response.objectForKey("Patient_Mrn_id") {
                                NSUserDefaults.standardUserDefaults().setObject(patientMrnId, forKey: "patient_id")
                                self.resumeAlertLabel.text = "Do you want to continue the last session for the patient \(patientName)"
                                self.showResumeSessionAlertView()
                            }
                        }
                        else
                        {

                        }
                    }
                    
                    
                }
                self.progressbarhidden()
                print("PatientScreen getPatientDetails end")
        }
    }
    
    /**
     Refresh the access token by sending the already stored access token to the server.
     */
    func getRefreshToken() {
        print("PatientScreen getRefreshToken begin")
        PFGlobalConstants.sendEventWithCatogory("background", action: "functionCall", label: "refreshToken", value: nil)
        let defaults = NSUserDefaults.standardUserDefaults()
        let patientID = defaults.integerForKey(PF_PatientIDOnDB)
        let refresh_token = defaults.stringForKey("refresh_token")! as String
        requestString = "\(baseURL)/login_dup"
        print(requestString)
        let clientID = "102216378240-rf6fjt3konig2fr3p1376gq4jrooqcdm"
        let clientSecret = "bYQU1LQAjaSQ1BH9j3zr7woO"
        url1 = NSURL(string: requestString as String)!
        urlRequest = NSMutableURLRequest(URL: url1)
        urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let patientModel = PFPatientDetailsModel()
        patientModel.loadvaluesParam(clientID, client_secret: clientSecret, refresh_token: refresh_token, grant_type: "refresh_token")
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
                    self.getPatientDetails(patientID)
                }
                print("PatientScreen getRefreshToken end")
        }
    }

    
    
    //MARK: Lock Screen Setup Delegate
    func pinSet(pin: String!, padLockScreenSetupViewController padLockScreenViewController: ABPadLockScreenSetupViewController!) {
        thePin = pin
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
        isAuthorizationRequesting = false;
        dismissViewControllerAnimated(true, completion: nil)
        self.userLoginService()
        self.warning.text = ""
        self.warning.textColor = UIColor.lightGrayColor()
    }
    
    func unlockWasUnsuccessful(falsePin: String!, afterAttemptNumber attemptNumber: Int, padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Failed Attempt \(attemptNumber) with incorrect pin \(falsePin)")
        if attemptNumber == 3
        {
            isAuthorizationRequesting = false;
            self.warning.text = "Incorrect passcode."
            self.warning.textColor = UIColor.redColor()
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func unlockWasCancelledForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Cancled")
        isAuthorizationRequesting = false;
        dismissViewControllerAnimated(true, completion: nil)
    }
}
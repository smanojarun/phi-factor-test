//
//  PFCameraviewcontrollerscreen.swift
//  PhiFactor
//
//  Created by Apple on 31/05/16.
//  Copyright © 2016 Hubino. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import AssetsLibrary
import CoreMotion
import Alamofire

/// Recording video by front and rear camera with flash availability. Presenting the preview for each video after the recording complition. Also provide the option to retake the video.
class PFCameraviewcontrollerscreen: GAITrackedViewController, AVCaptureFileOutputRecordingDelegate, UIAccelerometerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate, AppInactiveDelegate, PatientResumeDelegate {
    // Back button alert
    @IBOutlet var backButtonAlertCancel: UIButton!
    @IBOutlet var backButtonAlert: UIButton!
    @IBOutlet var backButtonAlertView: UIView!
    @IBOutlet var networkAlertView: UIView!
    @IBOutlet var netwrkAlertLabel: UILabel!
    @IBOutlet var retakeButtonAlert: UIButton!
    @IBOutlet var retakeButtonAlertView: UIView!
    @IBOutlet var uploadstatus: UIView!
    @IBOutlet var pfsHowtoTakeVideoView: UIView!
    @IBOutlet weak var PFSHbackrongimage: UIImageView!
    @IBOutlet weak var pauseaction: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var stopdemovedio: UIButton!
    @IBOutlet weak var startdemovedio: UIButton!
    // Back button
    @IBOutlet var backButtonView: UIView!
    @IBOutlet var previewBackground: UIImageView!
    // Acleometer
    @IBOutlet var pfcAcleometer: UIImageView!
    @IBOutlet weak var greenCircleView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var labelAxisY: UILabel!
    @IBOutlet weak var accelerometerView: UIView!
    @IBOutlet weak var accelerometerBGImageView: UIImageView!
    // vediou store view
    @IBOutlet weak var pfCameraStop: UIButton!
    @IBOutlet weak var pfCameraSview1: UIView!
    @IBOutlet weak var pfCameraSview2: UIView!
    @IBOutlet weak var pfCameraSview3: UIView!
    @IBOutlet weak var pfCameraSview4: UIView!
    // vediou store button
    @IBOutlet var pfPlaySubView4: UIButton!
    @IBOutlet var pfPlaySubView3: UIButton!
    @IBOutlet var pfPlaySubView2: UIButton!
    @IBOutlet var pfPlaySubView1: UIButton!
    @IBOutlet weak var pfCameraStartButton: UIButton!
    @IBOutlet var pfInfoselectButton: UIButton!
    @IBOutlet var uploadLabel: UILabel!
    // oval shape image and instruction label
    @IBOutlet var pfCameraFaceNotDetectedImageView: UIImageView!
    @IBOutlet var pfCameraFaceDetectedImageView: UIImageView!
    @IBOutlet var pfcCameraInstructionlabel: UILabel!
    // camera layer
    @IBOutlet var previewView: AVCamPreviewView!
    @IBOutlet var videoPreviewView: AVCamPreviewView!
    // camera properties and settings
    @IBOutlet var pfcFlashButton: UIButton!
    @IBOutlet var pfcBackButton: UIButton!
//    @IBOutlet var pfcDeletePreviousVideoButton: UIButton!
    @IBOutlet var pfcToggleCameraButton: UIButton!
    // counter
    @IBOutlet var pfcCameraCountdownLabel: UILabel!
    @IBOutlet var counterview: UIView!
    // animation
    @IBOutlet var pfcFaceAnimationImageView: UIImageView!
    @IBOutlet var pfcEyeAnimationImageView: UIImageView!
    // background layer
    @IBOutlet var pfcCameraBackgroundImageView: UIImageView!
    @IBOutlet var pfcEyeNotDetectedImageView: UIImageView!
    @IBOutlet var pfcEyeDetectedImageView: UIImageView!
    @IBOutlet var pfcCameraArrow: UIImageView!
    @IBOutlet var pfcPreviewPauseButton: UIButton!
    @IBOutlet var pfcPreviewRetakeButton: UIButton!
    @IBOutlet var pfcPreviewPlayButton: UIButton!
    @IBOutlet var pfcPreviewSubmitButton: UIButton!
    @IBOutlet var pfcPreviewSlider: UISlider!
    // heading label
    @IBOutlet var pfcVideoTitleLabel: UILabel!
    var  progressview: UIView!
    @IBOutlet var activityImageView: UIImageView!
    @IBOutlet var videothumbImageView1: UIImageView!
    @IBOutlet var videothumbImageView2: UIImageView!
    @IBOutlet var videothumbImageView3: UIImageView!
    @IBOutlet var videothumbImageView4: UIImageView!
    @IBOutlet var closeInfoVideoButton: UIButton!
    @IBOutlet var videoThumbView: UIView!
    @IBOutlet var startButtonBackgroundImageView: UIImageView!
    var blurEffectView = UIView()
    var myTimer = NSTimer()
    var previewTimer = NSTimer()
    var playTimer = NSTimer()
    var floatTime: Float!
    var duration: CMTime!
    var timeInSecond: Float!
    var newtime: CMTime!
    var videoCount: NSInteger!
    var retakeVideoCount: NSInteger!
    var patientModel: PFPatientDetailsModel?
    var canShowErrorMsg = true
    var playerlayer: Bool!
    var sessionRunningAndDeviceAuthorizedContext = "sessionRunningAndDeviceAuthorizedContext"
    var capturingStillImageContext = "capturingStillImageContext"
    var backgroundRecordId: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var deviceAuthorized: Bool  = false
    var cameraModel: PFCameraScreenModel?
    var runtimeErrorHandlingObserver: AnyObject?
    var global = PFGlobalConstants()
    var currentTime: Float!
    var totalDuration: Float!
    var sessionQueue: dispatch_queue_t!
    var session: AVCaptureSession?
    var videoDeviceInput: AVCaptureDeviceInput?
    var movieFileOutput: AVCaptureMovieFileOutput?
    var stillImageOutput: AVCaptureStillImageOutput?
    var sessionDelegatePF: CameraSessionControllerDelegate?
    var videoDeviceDataOutput = AVCaptureVideoDataOutput()
    var sessionRunningAndDeviceAuthorized: Bool {
        get {
            return (session?.running != nil && deviceAuthorized)
        }
    }
    var motionManager: CMMotionManager!
    // varibale declareing
    var tagvalue: NSNumber!
    var instructionstring: String!
    var isFaceorEyeDected = false
    var isPreviewScreen = false
    var count = Int()
    // Av player item declareing
    var iteminavPlayer3: NSURL!
    var iteminavPlayer4: NSURL!
    var iteminavPlayer5: NSURL!
    var iteminavPlayer6: NSURL!
    // Av player layer declareing
    var avAsset : AVAsset!
    var avPlayerItem : AVPlayerItem!
    var avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!

    var isRotationErrorOccured = false
    var canStartRecording = true
    var batteryCheckTimer :NSTimer!
    var isBatteryAlertShowing = false
    var isDocumentAlert = false
    var qualityCheck = true
    var resumeVideoCount : Int!
    var isResumeCameraViewEnabled = false
    var isShowingAlert = false
    var patientID = ""
    var documentAWSLink : String? =  nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CameraScreen viewDidLoad begin")
        self.screenName = PFCameraviewcontrollerScreenName
        // Acelometer
        self.initAccelometer()
        if let tempPatientId = NSUserDefaults.standardUserDefaults().stringForKey(PFPatientIDOnDB) {
            patientID = tempPatientId
        }

        cameraModel = PFCameraScreenModel()
        patientModel=PFPatientDetailsModel()
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PFCameraviewcontrollerscreen.showAlertandDelete),
                                                         name: "showAlert",
                                                         object: nil)
        // camera layer adding and start to record
        self.session = AVCaptureSession()
        self.previewView.session = session
        self.checkDeviceAuthorizationStatus()
        let sessionQueue: dispatch_queue_t = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
        self.sessionQueue = sessionQueue
        dispatch_async(sessionQueue, {
            self.backgroundRecordId = UIBackgroundTaskInvalid
            let videoDevice: AVCaptureDevice! = PFCameraviewcontrollerscreen.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.Back)
            var error: NSError? = nil
            var videoDeviceInput: AVCaptureDeviceInput?
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            } catch let error1 as NSError {
                error = error1
                videoDeviceInput = nil
            } catch {
                fatalError()
            }
            if(error != nil) {
                print(error)
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            if self.session?.canAddInput(videoDeviceInput) == true {
                self.session?.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                    dispatch_async(dispatch_get_main_queue(), {
                    // Why are we dispatching this to the main queue?
                    // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                    // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                            let orientation: AVCaptureVideoOrientation =  AVCaptureVideoOrientation(rawValue: self.interfaceOrientation.rawValue)!
                    (self.previewView.layer as! AVCaptureVideoPreviewLayer).connection.videoOrientation = orientation
                        })
                }
            let audioDevice: AVCaptureDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio).first as! AVCaptureDevice
            var audioDeviceInput: AVCaptureDeviceInput?
            do {
                audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            } catch let error2 as NSError {
                error = error2
                audioDeviceInput = nil
                PFGlobalConstants.sendException("NoAudioInput", isFatal: false)
            } catch {
                fatalError()
                PFGlobalConstants.sendException("NoAudioInput", isFatal: false)
            }
            if error != nil {
                print (error)
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            if self.session?.canAddInput(audioDeviceInput) == true {
                self.session?.addInput (audioDeviceInput)
            }
            let currentVideoDevice: AVCaptureDevice = self.videoDeviceInput!.device
            let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
            let bool: Bool=(self.global.isDeviceCompatibile())
            if(currentPosition == AVCaptureDevicePosition.Back) && (bool) {
                self.session!.sessionPreset = AVCaptureSessionPresetiFrame960x540
            }
            else {
                self.session!.sessionPreset = AVCaptureSessionPresetiFrame960x540
            }
            self.addCameraDataOutput()
            let movieFileOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
            self.movieFileOutput = movieFileOutput
        })
        
        pfCameraSview1.hidden=true
        pfCameraSview2.hidden=true
        pfCameraSview3.hidden=true
        pfCameraSview4.hidden=true
//        pfcDeletePreviousVideoButton.hidden = true
        counterview.hidden=true
        playerlayer=false
        
        // Video store button hide
        pfPlaySubView1.hidden=true
        pfPlaySubView2.hidden=true
        pfPlaySubView3.hidden=true
        pfPlaySubView4.hidden=true
        // Preview hidden
        pfcPreviewRetakeButton.hidden=true
        pfcPreviewPlayButton.hidden=true
        pfcPreviewSubmitButton.hidden=true
        // animation view hidden
        pfcFaceAnimationImageView.hidden=true
        pfcEyeAnimationImageView.hidden=true
        // background hidden
        pfcCameraBackgroundImageView.hidden=false
        pfcEyeNotDetectedImageView.hidden=true
        pfcEyeDetectedImageView.hidden=true
        self.pfcPreviewSubmitButton.tag=460
        // slider hidden and pause
         pfcPreviewSlider.hidden=true
        pfcPreviewPauseButton.hidden=true
        instructionstring=introVideoInstruction
        videoCount = 1
        retakeVideoCount=0
        // animation
        var arrayOfImages: [UIImage] = []
        for i in 1..<31 {
            let image = String(format: "FaceAnimationLayer%d", i)
            arrayOfImages.append(UIImage(named: image)!)
        }
        pfcFaceAnimationImageView.animationImages = arrayOfImages
        pfcFaceAnimationImageView.animationDuration = 5
        pfcFaceAnimationImageView.animationRepeatCount = 1
        var arrayOfImagesstrainghtdot: [UIImage] = []
        for i in 1..<18 {
            let image = String(format: "lineDot%d", i)
            arrayOfImagesstrainghtdot.append(UIImage(named: image)!)
        }
        pfcEyeAnimationImageView.animationImages = arrayOfImagesstrainghtdot
        pfcEyeAnimationImageView.animationDuration = 15
        pfcEyeAnimationImageView.animationRepeatCount = 1
        var arrayOfImagesarrow: [UIImage] = []
        for j in 1..<5 {
            let image = String(format: "camera_arrow%d", j)
            arrayOfImagesarrow.append(UIImage(named: image)!)
        }
        pfcCameraArrow.animationImages = arrayOfImagesarrow
        pfcCameraArrow.animationDuration = 2
        pfcCameraArrow.animationRepeatCount = 1
        
        batteryCheckTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(PFCameraviewcontrollerscreen.batteryStatusCheck), userInfo: nil, repeats: true)
        let documentPath = String(format: "\(NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0])/maimagepickercontollerfinalimage.jpg")
        let imageData = NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("loading", withExtension: "gif")!)
        self.activityImageView.image = UIImage.gifWithData(imageData!)
        self.activityImageView.hidden = true
        if (NSData(contentsOfFile: documentPath) != nil)
        {
            let cameraModel = PFCameraScreenModel()
            documentAWSLink = cameraModel.uploadDocument(documentPath, patientId: patientID)
            self.isDocumentAlert = true
            self.showAlertandDelete()
        }
        
        let filePath = NSBundle.mainBundle().pathForResource("video1", ofType: "mp4")!
        avAsset = AVAsset(URL: NSURL.fileURLWithPath(filePath))
        avPlayerItem = AVPlayerItem(asset: avAsset)
        avPlayer = AVPlayer(playerItem: avPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.videoPreviewView.layer.addSublayer(avPlayerLayer)
        self.avPlayerLayer.hidden = true
        avPlayer.seekToTime(kCMTimeZero)
        previewTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(PFCameraviewcontrollerscreen.updateSlider), userInfo: nil, repeats: true)
        pfcPreviewSlider.addTarget(self, action: #selector(PFCameraviewcontrollerscreen.sliderValueDidChange(_:)), forControlEvents: UIControlEvents.ValueChanged)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PFCameraviewcontrollerscreen.pfCameraStopthevedio),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: nil)
        pfcPreviewSlider.minimumValue = 0.0
        pfcPreviewSlider.continuous = true
        closeInfoVideoButton.hidden = true
        let qualityCheckStatus = PFQualityCheck.stringByReplacingOccurrencesOfString("X", withString: user)
        let isQualityCheckOn = NSUserDefaults.standardUserDefaults().objectForKey(qualityCheckStatus)?.boolValue
        if isQualityCheckOn != nil && isQualityCheckOn?.boolValue == false
        {
            qualityCheck = false
        }

        // hiding button
        if qualityCheck {
            pfCameraStartButton.hidden=true
            pfCameraStop.hidden=true
        }
        if isResumeCameraViewEnabled
        {
            self.updateViewForResumeAction()
        }
        print("CameraScreen viewDidLoad end")

    }
    override func viewDidLayoutSubviews() {
        
    }

    override func viewDidDisappear(animated: Bool) {
        print("CameraScreen viewDidDisappear begin")
        self.removeCameraMovieOutput()
        self.removeCameraDataOutput()
        myTimer.invalidate()
        avPlayer = AVPlayer()
        motionManager?.stopAccelerometerUpdates()
        motionManager = nil
        self.removeObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", context: &self.sessionRunningAndDeviceAuthorizedContext)
        self.removeObserver(self, forKeyPath: "stillImageOutput.capturingStillImage" ,context: &self.capturingStillImageContext)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("CameraScreen viewDidDisappear end")
    }

    override func viewWillAppear(animated: Bool) {
        print("CameraScreen viewWillAppear begin")
        APP_DELEGATE?.inactiveDelegate = self
        self.pfcCameraInstructionlabel.hidden = false
        if qualityCheck {
            self.pfCameraStartButton.enabled = false
        }
        self.pfCameraStop.enabled = false

        dispatch_async(self.sessionQueue, {
            self.addObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", options: [.Old , .New] , context: &self.sessionRunningAndDeviceAuthorizedContext)
            self.addObserver(self, forKeyPath: "stillImageOutput.capturingStillImage", options: [.Old , .New], context: &self.capturingStillImageContext)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PFCameraviewcontrollerscreen.subjectAreaDidChange(_:)), name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput?.device)
            print("name date")
            weak var weakSelf = self
            self.runtimeErrorHandlingObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureSessionRuntimeErrorNotification, object: self.session, queue: nil, usingBlock: {
                (note: NSNotification?) in
                print(note)
                PFGlobalConstants.sendException("AVCaptureSessionRuntimeErrorNotification", isFatal: false)
                let strongSelf: PFCameraviewcontrollerscreen = weakSelf!
                dispatch_async(strongSelf.sessionQueue, {
                    //                    strongSelf.session?.startRunning()
                    if let sess = strongSelf.session{
                        if self.session?.running == false
                        {
                            sess.startRunning()
                            print("name date2")
                        }
                    }
                })
                })
            print("name date3")
            self.session?.startRunning()
        })
        print("CameraScreen viewWillAppear end")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &capturingStillImageContext {
            let isCapturingStillImage: Bool = change![NSKeyValueChangeNewKey]!.boolValue
            if isCapturingStillImage {
            }
        }
        else {
            return super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    /**
     adding camera movie output to currently running session.
     */
    
    func addCameraMovieOutput() {
        print("CameraScreen addCameraMovieOutput begin")
        PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "addCameraMovieOutput", value: nil)
        if self.session?.running == true {

            self.movieFileOutput =  AVCaptureMovieFileOutput()
            if self.session!.canAddOutput(self.movieFileOutput) {
                self.session!.addOutput(self.movieFileOutput)
                let connection: AVCaptureConnection? = movieFileOutput!.connectionWithMediaType(AVMediaTypeVideo)
                let stab = connection?.supportsVideoStabilization
                if (stab != nil) {
                    if connection?.supportsVideoStabilization == true {
                        connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Cinematic
                    }
                    //                    connection!.enablesVideoStabilizationWhenAvailable = true
                }
                    //                self.movieFileOutput = movieFileOutput
                print("output")
                }
            else {
                print("movie file output not added.")
                PFGlobalConstants.sendException("addCameraMovieOutputFailed", isFatal: false)
            }
        }
        else {

            print("Session not running")
            PFGlobalConstants.sendException("NoSessionRunningWhileAddCameraMovieOutput", isFatal: false)
        }
        print("CameraScreen addCameraMovieOutput end")
    }

    /**
     Removing sample data buffer delegate from the currently running session.
     Adding the movie file output to the running session.
     Changing the preset to AVCaptureSessionPreset3840x2160 or AVCaptureSessionPresetHigh depends on the currently selected camera
     Check the flash mode is currently enabled or not.If its enabled turn on flash after commit configuration.
     */
    
    func removeCameraDataAndAddMovieoutput() {
        print("CameraScreen removeCameraDataAndAddMovieoutput begin")
        PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "addCameraMovieOutput", value: nil)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            print("Recording start Action")
            if self.session?.running == true {
                print("session running")
                var flashModeOn : Bool
                let currentVideoDevice: AVCaptureDevice = self.videoDeviceInput!.device
                let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
                if(currentPosition == AVCaptureDevicePosition.Front){
                     flashModeOn = true
                }
                else{
                    flashModeOn = false
                }

                let bool: Bool=(self.global.isDeviceCompatibile())
                if(currentPosition == AVCaptureDevicePosition.Back) && (bool) {
                    if self.videoDeviceInput?.device.hasTorch == true {
                        if self.videoDeviceInput?.device.torchActive == true {
                            flashModeOn = true
                        }
                    }
                }
                else {
                    if self.videoDeviceInput?.device.hasTorch == true {
                        if self.videoDeviceInput?.device.torchActive == true {
                            flashModeOn = true
                        }
                    }
                }
                
                self.session?.stopRunning()
                self.session?.beginConfiguration()
                if(currentPosition == AVCaptureDevicePosition.Back) && (bool) {
                    print("4K preset begin")
                    self.session?.sessionPreset = AVCaptureSessionPreset3840x2160
                    print("4k preset success.")
                }
                else {
                        print("front preset begin")
                        self.session?.sessionPreset = AVCaptureSessionPresetHigh
                        print("front preset success")
                }
                
                self.session!.removeOutput(self.videoDeviceDataOutput)
                print("Video output removed.")
                self.session?.removeOutput(self.movieFileOutput)
                print("Movie output removed.")
                self.movieFileOutput = AVCaptureMovieFileOutput()
                if self.session?.canAddOutput(self.movieFileOutput) == true {
                    self.session?.addOutput(self.movieFileOutput)
                    print("movie output added")
                }
                else {
                    print("movie file output not added.")
                }
                self.session?.commitConfiguration()
                self.session?.startRunning()
                
                if flashModeOn {
                    let currentVideoDevice: AVCaptureDevice = self.videoDeviceInput!.device
                    let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
                    if AVCaptureDevicePosition.Front==currentPosition{
                        if self.videoDeviceInput!.device.hasTorch {
                            // lock your device for configuration
                            do {
                                let abv = try self.videoDeviceInput!.device.lockForConfiguration()
                                print(abv)
                            } catch {
                                print("Error while lockForConfiguration")
                            }
                            self.videoDeviceInput!.device.torchMode = AVCaptureTorchMode.On
                            self.videoDeviceInput!.device.unlockForConfiguration()
                        }}
                    else {
                        // check if the device has torch
                        if self.videoDeviceInput!.device.hasTorch {
                            // lock your device for configuration
                            do {
                                let abv = try self.videoDeviceInput!.device.lockForConfiguration()
                            } catch {
                                print("Error while lockForConfiguration")
                            }
                            // check if your torchMode is on or off. If on turns it off otherwise turns it on
                            do {
                                let abv = try self.videoDeviceInput!.device.setTorchModeOnWithLevel(1.0)
                            } catch {
                                print("Error while setTorchModeOnWithLevel")
                            }
                            // unlock your device
                            self.videoDeviceInput!.device.unlockForConfiguration()
                        }
                    }
                }
        
            }
            else {
                print("Session not running")
                PFGlobalConstants.sendException("NoSessionRunningWhileRemoveCameraDataAndAddMovieoutput", isFatal: false)
            }
        }
        let seconds = 0.50
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.startRecordingAction()
        })
        print("CameraScreen removeCameraDataAndAddMovieoutput end")
    }
    
    /**
     Removing the movie file output delegate and adding the camera data output to currently running seeion.
     Also change the sesion preset to the AVCaptureSessionPresetiFrame960x540.
     */
    
    func removeMovieDataAndAddCameraDataOuput() {
        print("CameraScreen removeMovieDataAndAddCameraDataOuput begin")
        PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "removeMovieDataAndAddCameraDataOuput", value: nil)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            print("Recording stop Action")
            if self.session?.running == true {
                print("Session running")
                self.session?.stopRunning()
                self.session?.beginConfiguration()
                print("Preset begin")
                self.session?.sessionPreset = AVCaptureSessionPresetiFrame960x540
                print("Preset success")
                print("Movie output remove begin")
                self.session?.removeOutput(self.movieFileOutput)
                print("Movie output remove success")
                if self.session!.canAddOutput(self.videoDeviceDataOutput) {
                    print("Add videoDeviceDataOutput begin")
                    self.session!.addOutput(self.videoDeviceDataOutput)
                    print("Add videoDeviceDataOutput success")
                }
                else {
                    print("Cannot add videoDeviceDataOutput")
                }
                self.session?.commitConfiguration()
                self.session?.startRunning()
            }
            else {
                print("Session not running")
                PFGlobalConstants.sendException("NoSessionRunningWhileRemoveMovieDataAndAddCameraDataOuput", isFatal: false)
            }
            print("CameraScreen removeMovieDataAndAddCameraDataOuput end")
        }
    }

    /**
     Preset the camera session preset to AVCaptureSessionPresetiFrame960x540 even its Front or Rear camera.
     */
    
    func setCamerasession() {
        print("CameraScreen setCamerasession begin")
        PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "setCamerasession", value: nil)
        self.session?.beginConfiguration()
        let currentVideoDevice: AVCaptureDevice = self.videoDeviceInput!.device
        let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
        let bool: Bool=(global.isDeviceCompatibile())
        if(currentPosition == AVCaptureDevicePosition.Back) && (bool) {
            self.session!.sessionPreset = AVCaptureSessionPresetiFrame960x540
        }
        else {
            self.session!.sessionPreset = AVCaptureSessionPresetiFrame960x540
        }
        self.session?.commitConfiguration()
        print("CameraScreen setCamerasession end")
    }

    /**
     Remove the camera movieFileoutput from the currently running session.
     */
    
    func removeCameraMovieOutput() {
        print("CameraScreen removeCameraMovieOutput begin")
        PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "removeCameraMovieOutput", value: nil)
        if self.session?.running == true {

            self.session?.beginConfiguration()
            self.session!.removeOutput(movieFileOutput)
            self.session?.commitConfiguration()
        }
        else {

            print("Session not running")
            PFGlobalConstants.sendException("NoSessionRunningWhileRemoveCameraMovieOutput", isFatal: false)
        }
        print("CameraScreen removeCameraMovieOutput end")
    }

    /**
     Adding the video sample buffer data to the currntly running session.
     Videosetting for sample buffer also initialized.
     */
    
    func addCameraDataOutput() {
        print("CameraScreen addCameraDataOutput begin")
        PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "addCameraDataOutput", value: nil)
        videoDeviceDataOutput.videoSettings = NSDictionary(object: Int(kCVPixelFormatType_32BGRA), forKey: kCVPixelBufferPixelFormatTypeKey as String) as! [NSObject: AnyObject]
        videoDeviceDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDeviceDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        if self.session!.canAddOutput(videoDeviceDataOutput) {
            self.session!.addOutput(videoDeviceDataOutput)
        }
        print("CameraScreen addCameraDataOutput end")
    }

    /**
     Removing the video sample buffer data from the currntly running session.
     */
    
    func removeCameraDataOutput() {
        print("CameraScreen removeCameraDataOutput begin")
        PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "removeCameraDataOutput", value: nil)
        if self.session?.running == true {
            print("session running")
            self.session?.beginConfiguration()
            videoDeviceDataOutput = AVCaptureVideoDataOutput()
            self.session!.removeOutput(videoDeviceDataOutput)
            self.session?.commitConfiguration()
        }
        else {
            print("videoDeviceDataOutput not removed")
            PFGlobalConstants.sendException("videoDeviceDataOutputNotRemoved", isFatal: false)
        }
        print("CameraScreen removeCameraDataOutput end")
    }

    //    func validateVideofromURL(notification: NSNotification) {
    //
    //        let videoURL = notification.userInfo!["videoURL"] as! NSURL
    //
    //        print(videoURL)
    //
    //        let instanceOfCustomObject: CVResult = CVResult()
    //
    //        let errorCode = instanceOfCustomObject.getVideoResult(videoURL,videoCount)
    //
    //        if errorCode == 1 {
    //            print("Success")
    //            activityView.completeLoading(true)
    //        }

    //        else {
    //            activityView.completeLoading(false)
    //            print("Failed")
    //        }

    //    }

    /* AVCaptureVideoDataOutput Delegate
     ------------------------------------------*/
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        if (connection.supportsVideoOrientation) {
            //connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        }
        if (connection.supportsVideoMirroring) {
            //connection.videoMirrored = true
            connection.videoMirrored = false
        }
        sessionDelegatePF?.cameraSessionDidOutputSampleBuffer?(sampleBuffer)
        let image = sampleBuffer.toUIImage()
        let instanceOfCustomObject: CVResult = CVResult()
        let currentVideoDevice: AVCaptureDevice = self.videoDeviceInput!.device
        let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
        var errorCode: UnsafeMutablePointer<Int32>
        if(currentPosition == AVCaptureDevicePosition.Back) {
            errorCode = instanceOfCustomObject.getErrorCode(image,videoCount,retakeVideoCount, true)
        }
        else {
            errorCode = instanceOfCustomObject.getErrorCode(image,videoCount,retakeVideoCount, false)
        }
        pfcCameraInstructionlabel.hidden = false
        var someInts: [CInt] = []
        for i in 0...16 {
            someInts.append(errorCode[i])
        }
        var successValue = 0
        if canShowErrorMsg {
            if canStartRecording == true {
                self.pfcCameraInstructionlabel.hidden=false
                for i in 0...14 {
                    if someInts[i] == 1001 {
                        showErrorMessage("Face not detected")
                        showRedColor()
                        successValue = 1
                    }
                    if someInts[i] == 1002 {
                        showErrorMessage("Face not in Center")
                        showRedColor()
                        successValue = 1
                    }
                    if someInts[i] == 1003 {
                        showErrorMessage("Face not in Area")
                        showRedColor()
                        successValue = 1
                    }
                    if someInts[i] == 1004 {
                        showErrorMessage("Position patient further from camera ")
                        showRedColor()
                        successValue = 1
                    }
                    if someInts[i] == 1005 {
                        showErrorMessage("Position patient closer to camera ")
                        showRedColor()
                        successValue = 1
                    }
                    if someInts[i] == 1006 {
                        showErrorMessage("Check the lighting condition")
                        showRedColor()
                        successValue = 1
                    }
                    if someInts[i] == 1007 {
                        showErrorMessage("Keep straight to the camera")
                        successValue = 1
                        showRedColor()
                    }
                    if someInts[i] == 1009 {
                        showErrorMessage("Face not detected due to lighting")
                        successValue = 1
                        showRedColor()
                    }
                    if someInts[i] == 1 && i != 13 {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.pfCameraStartButtonaction(nil)
                            self.showGreenColor()
                        }
                    }
                    if someInts[i] == 3002 {
                        showErrorMessage("Eye not detected")
                        successValue = 1
                        showRedColor()
                    }
                    if someInts[i] == 3003 {
                        showErrorMessage("Eye too small")
                        showRedColor()
                        successValue = 1
                    }
                    if someInts[i] == 3004 {
                        showErrorMessage("Eye not in center ")
                        showRedColor()
                        successValue = 1
                    }
                    if someInts[i] == 3005 {
                        showErrorMessage("Eye too large")
                        showRedColor()
                        successValue = 1
                    }
                }
                if  successValue == 0 {
                    showErrorMessage("Please be stand still")
                    showGreenColor()
                }
            }
            else
            {
                showErrorMessage("Tilt device to 0\u{00B0}")
            }
            
        }
        else {

            self.pfcCameraInstructionlabel.hidden=true
        }
    }

    /**
     Showing the error message label with the given errorCodeStr
      - parameter errorCodeStr: string value to be shown on errror message
     */
    
    func showErrorMessage(errorCodeStr: NSString) {
        dispatch_async(dispatch_get_main_queue()) {
            if self.pfcCameraInstructionlabel.text != errorCodeStr
            {
                self.pfcCameraInstructionlabel.pushTransition(1)
                self.pfcCameraInstructionlabel.text = errorCodeStr as String
            }
        }
    }

    /**
     Showing the face or eye detection status true by displaying the respective overlay on interface.
     */
    
    func showGreenColor() {
        dispatch_async(dispatch_get_main_queue(), {
            if(self.videoCount == 4) {
                self.pfcEyeNotDetectedImageView.hidden=true
                self.pfcEyeDetectedImageView.hidden=false
            }else {
                self.pfCameraFaceDetectedImageView.hidden=false
                self.pfCameraFaceNotDetectedImageView.hidden=true
            }
        })
    }

    /**
     Showing the face or eye detection status false by displaying the respective overlay on interface.
     */
    
    func showRedColor() {
        dispatch_async(dispatch_get_main_queue(), {
            if(self.videoCount == 4) {
                self.pfcEyeNotDetectedImageView.hidden=false
                self.pfcEyeDetectedImageView.hidden=true
            }else {
                self.pfCameraFaceDetectedImageView.hidden=true
                self.pfCameraFaceNotDetectedImageView.hidden=false
            }
        })
    }

    /**
     Start button action touchupInside from interface.
     Initiating the movieFileOutput recording.
     Before start recording current session should be configured by calling the removeCameraDataAndAddMovieoutput function.
      - parameter sender: start button from interface
     */
    
    @IBAction func pfCameraStartButtonaction(sender: AnyObject? = nil) {
        print("CameraScreen pfCameraStartButtonaction begin")
        if self.pfCameraStartButton.userInteractionEnabled {
            self.pfCameraStartButton.userInteractionEnabled = false
            PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "pfCameraStartButtonaction", value: nil)
            if self.videoCount == 1
            {
                self.pfcFaceAnimationImageView.animationDuration = 5
                self.pfcCameraCountdownLabel.text = "5"
            }
            else
            {
                self.pfcFaceAnimationImageView.animationDuration = 15
                self.pfcCameraCountdownLabel.text = "15"
            }
            self.isRotationErrorOccured = false
            backButtonCancel()
            self.pfInfoselectButton.hidden = true
            self.backButtonView.hidden = true
            // counter start and unhidden
            counterview.hidden=false
            pfcToggleCameraButton.hidden = true
            pfcCameraArrow.hidden = true
//            pfcDeletePreviousVideoButton.hidden = true
            if !qualityCheck {
                self.pfCameraStartButton.hidden=true
                self.pfCameraStop.hidden = false
            }
            else {
                self.pfCameraStartButton.hidden=true
                self.pfCameraStop.hidden = true
            }
            
            // check the accelerometer
            if(isFaceorEyeDected == false) {
                pfcEyeAnimationImageView.hidden=true
                pfcFaceAnimationImageView.hidden=false
            }
            else {
                
                pfcFaceAnimationImageView.hidden=true
                pfcEyeAnimationImageView.hidden=false
            }
            self.removeCameraDataAndAddMovieoutput()
        }
        else {
            print("Camera toggling is on progress.")
        }
        print("CameraScreen pfCameraStartButtonaction end")
    }

    /**
     Initiating the movieFileOutput and start recording on main queue.
     Timer enabled for auto stop recording.
     Also recording output filepath initialized.
     */
    func startRecordingAction()
    {
        print("CameraScreen startRecordingAction begin")
        PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "startRecordingAction", value: nil)
        dispatch_async(dispatch_get_main_queue(), {
            if self.movieFileOutput?.recording == false {
                if self.videoCount == 1
                {
                    self.count=5
                }
                else
                {
                    self.count=15
                }
                    self.myTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                PFCameraviewcontrollerscreen.setFlashMode(AVCaptureFlashMode.Auto, device: self.videoDeviceInput!.device)

                    let date = NSDate()
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyyMMddHHmmss"
                formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
                formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                let dateFormatter = formatter.stringFromDate(date)
                    let moviePath = NSString .localizedStringWithFormat("phifactor_%@.MOV", dateFormatter)
                    let outputFilePath  =
                    NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(moviePath as String)
                    self.movieFileOutput?.startRecordingToOutputFileURL (outputFilePath, recordingDelegate: self)
                switch(self.videoCount) {
                case 1:
                    self.pfcCameraInstructionlabel.text = introVideoInstruction
                    break
                case 2:
                    self.pfcCameraInstructionlabel.text = facialVideoInstruction
                    break
                case 3:
                    self.pfcCameraInstructionlabel.text = headVideoInstruction
                    break
                case 4:
                    self.pfcCameraInstructionlabel.text = eyeVideoInstruction
                    break
                default:
                    break
                }
            }
            else {
                }
            print("CameraScreen startRecordingAction end")
        })
    }

    /**
     Stop button action touchupInside from interface.
     Stopping the movieFileOutput recording.
     After stop recording timer will be invalidated.
     - parameter sender: Stop button from interface
     */
    @IBAction func pfCameraStopaction(sender: AnyObject) {
        if self.movieFileOutput?.recording == true {
            print("CameraScreen pfCameraStopaction begin")
            PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "pfCameraStopaction", value: nil)
            self.myTimer.invalidate()
            pfcFaceAnimationImageView.stopAnimating()
            pfcEyeAnimationImageView.stopAnimating()
            pfcFaceAnimationImageView.hidden=true
            pfcEyeAnimationImageView.hidden = true
            
            self.movieFileOutput!.stopRecording()
            self.pfInfoselectButton.hidden = true
            count=0-1
            // hideing button
            pfCameraStartButton.hidden=true
            pfCameraStop.hidden=true
            counterview.hidden = true
            pfcCameraCountdownLabel.text = "15"
            self.pfCameraFaceDetectedImageView.hidden=true
            self.pfCameraFaceNotDetectedImageView.hidden=true
//            self.pfcEyeNotDetectedImageView.hidden=true
//            self.pfcEyeDetectedImageView.hidden=true
            pfcToggleCameraButton.hidden = true
            pfcCameraArrow.hidden = true
            print("CameraScreen pfCameraStopaction end")
        }
        else {
            print("MovieFileOutput recording is stopped.")
        }
    }

    /**
     Camera retake action from interface.
     Hidding and unhidding the necessary elements on interface and adding the AVPreview layer to play the recorded video.
     - parameter sender: reatake button from interface
     */
    @IBAction func pfc_preview_retakeaction(sender: AnyObject) {
        print("CameraScreen pfc_preview_retakeaction begin")
        PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "retakeAction", value: nil)
        if !qualityCheck
        {
            pfCameraStartButton.hidden = false
            self.pfCameraStartButton.userInteractionEnabled = true
        }
        avPlayer.pause()
        self.avPlayerLayer.hidden = true
        self.pfInfoselectButton.hidden = false
        previewBackground.hidden = true
        self.previewView.hidden = false
        retakeVideoCount = 1
        canShowErrorMsg = true
        self.pfcCameraArrow.hidden = false
        if !isResumeCameraViewEnabled {
            self.backButtonView.hidden = false
        }
        // preview hidden
        pfcPreviewRetakeButton.hidden=true
        pfcPreviewPlayButton.hidden=true
        pfcPreviewSubmitButton.hidden=true
        // unhidden camera functions
        pfcToggleCameraButton.hidden=false
        // acleometer unhidden
        pfcAcleometer.hidden=false
        contentView.hidden=false
        accelerometerView.hidden = false
        // cancel unhidden
        if videoCount != nil && videoCount == 0 {
//            pfcDeletePreviousVideoButton.hidden=true
            self.pfcCameraCountdownLabel.text = "5"
        }
        else {
            
            if tagvalue != nil {
//                pfcDeletePreviousVideoButton.hidden=false
                self.pfcCameraCountdownLabel.text = "15"
            }
            else {
//                pfcDeletePreviousVideoButton.hidden=true
                self.pfcCameraCountdownLabel.text = "5"
                hideDeletePreviousVideoButtonIfResumeCount(videoCount)
            }
        }
        if videoCount != nil {
            if videoCount == 4 {
                pfcCameraBackgroundImageView.hidden = true
                pfcEyeNotDetectedImageView.hidden = false
                pfcEyeDetectedImageView.hidden = false
            }
            else {
                pfcCameraBackgroundImageView.hidden = false
                pfcEyeNotDetectedImageView.hidden = true
                pfcEyeDetectedImageView.hidden = true
            }
        }
        let currentVideoDevice: AVCaptureDevice = self.videoDeviceInput!.device
        let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
        switch currentPosition{
        case AVCaptureDevicePosition.Front:
            self.pfcFlashButton.hidden = true
        case AVCaptureDevicePosition.Back:
            self.pfcFlashButton.hidden = false
        case AVCaptureDevicePosition.Unspecified:
            self.pfcFlashButton.hidden = false
        }

        pfcBackButton.hidden=false
        isPreviewScreen = false
        // instruction label unhidden
        pfcCameraInstructionlabel.hidden=false
        pfcVideoTitleLabel.hidden=false
        print("CameraScreen pfc_preview_retakeaction end")
    }

    /**
     Removing the demo video layer from the super view.
      - parameter sender: remove button
     */
    @IBAction func removedemovediou(sender: AnyObject) {
        print("CameraScreen removedemovediou begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "removeDemoeVideo", value: nil)
        avPlayer.pause()
        playTimer.invalidate()
        slider.hidden=true
        closeInfoVideoButton.hidden = true
        self.pfcCameraArrow.hidden = false
        if !isResumeCameraViewEnabled {
            self.backButtonView.hidden = false
        }
        self.previewBackground.hidden = true
        self.previewView.hidden = false
        self.pfInfoselectButton.hidden = false
        let currentVideoDevice: AVCaptureDevice = self.videoDeviceInput!.device
        let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
        switch currentPosition{
        case AVCaptureDevicePosition.Front:
            self.pfcFlashButton.hidden = true
        case AVCaptureDevicePosition.Back:
            self.pfcFlashButton.hidden = false
        case AVCaptureDevicePosition.Unspecified:
            self.pfcFlashButton.hidden = false
        }
        self.pfcCameraBackgroundImageView.hidden = false
        pfcFaceAnimationImageView.hidden=true
        self.pfcVideoTitleLabel.hidden = false
        self.avPlayerLayer.hidden = true
        self.pfcPreviewPlayButton.hidden = true
        self.pfcPreviewPauseButton.hidden = true
        self.pfcToggleCameraButton.hidden = false
        self.pfcPreviewSlider.hidden = true
        self.contentView.hidden = false
        accelerometerView.hidden = false
        self.pfcAcleometer.hidden = false
        if !qualityCheck {
            pfCameraStartButton.hidden = false
            self.pfCameraStartButton.userInteractionEnabled = true
        }
        self.pfcCameraInstructionlabel.hidden=false
        // disable the button
        self.canShowErrorMsg = true
        
        if videoCount == 4
        {
            self.pfcEyeNotDetectedImageView.hidden=false
            self.pfcEyeDetectedImageView.hidden=false
        }
        else
        {
            self.pfCameraFaceDetectedImageView.hidden=false
            self.pfCameraFaceNotDetectedImageView.hidden=false
        }
        if videoCount != nil && videoCount == 0 {
//            pfcDeletePreviousVideoButton.hidden=true
        }
        else {
            
            if tagvalue != nil {
//                pfcDeletePreviousVideoButton.hidden=false
                hideDeletePreviousVideoButtonIfResumeCount(videoCount)
            }
            else {
//                pfcDeletePreviousVideoButton.hidden=true
            }
        }
        self.startButtonBackgroundImageView.hidden = false
        self.videoThumbView.hidden = false
        print("CameraScreen removedemovediou end")
    }

    /**
     Playing the demo video by adding the AVPlayer layer to the super view.
     Adding the slider for seeking the video.
     - parameter sender: play button on interface
     */
    @IBAction func playdemovediou(sender: AnyObject) {
        print("CameraScreen playdemovediou begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "playDemoVideo", value: nil)
        slider.hidden=false
              playTimer   = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(PFCameraviewcontrollerscreen.updateSliderInfo), userInfo: nil, repeats: true)
        slider.addTarget(self, action: #selector(PFCameraviewcontrollerscreen.sliderValueDidChangeInfo(_:)), forControlEvents: UIControlEvents.ValueChanged)
        slider.minimumValue = 0.0
        slider.continuous = true
        playerlayer=true
        pauseaction.hidden=false
        stopdemovedio.hidden=true
        print("CameraScreen playdemovediou end")
    }

    /**
     Selecting the camera front or rear.
      - parameter sender: camera select button
     */
    @IBAction func pfcp_pcameraselete_action(sender: UIButton) {
        if self.pfcToggleCameraButton.userInteractionEnabled == true {
            print("CameraScreen pfcp_pcameraselete_action begin")
            PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "toggleCamera", value: nil)
            dispatch_async(dispatch_get_main_queue()) {
                self.activityImageView.hidden = false
            }
            self.pfcToggleCameraButton.userInteractionEnabled = false
            self.pfCameraStartButton.userInteractionEnabled = false
            sender.enabled = false
            self.pfcToggleCameraButton.hidden = true
            self.pfcCameraArrow.hidden = true
            self.session!.removeOutput(self.videoDeviceDataOutput)
            
            let currentVideoDevice: AVCaptureDevice = self.videoDeviceInput!.device
            let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
            switch currentPosition{
            case AVCaptureDevicePosition.Front:
                self.pfcFlashButton.hidden = false
            case AVCaptureDevicePosition.Back:
                self.pfcFlashButton.hidden = true
            case AVCaptureDevicePosition.Unspecified:
                self.pfcFlashButton.hidden = false
            }
            dispatch_async(self.sessionQueue) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    
                    
                    return
                }
                let currentVideoDevice: AVCaptureDevice = self.videoDeviceInput!.device
                let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
                var preferredPosition: AVCaptureDevicePosition = AVCaptureDevicePosition.Unspecified
                switch currentPosition{
                case AVCaptureDevicePosition.Front:
                    preferredPosition = AVCaptureDevicePosition.Back
                    self.pfcFlashButton.hidden = false
                case AVCaptureDevicePosition.Back:
                    preferredPosition = AVCaptureDevicePosition.Front
                    self.pfcFlashButton.hidden = true
                    self.pfcFlashButton.hidden = true
                case AVCaptureDevicePosition.Unspecified:
                    preferredPosition = AVCaptureDevicePosition.Back
                    self.pfcFlashButton.hidden = false
                }
                
                let device: AVCaptureDevice = PFCameraviewcontrollerscreen.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: preferredPosition)
                var videoDeviceInput: AVCaptureDeviceInput?
                do {
                    videoDeviceInput = try AVCaptureDeviceInput(device: device)
                } catch _ as NSError {
                    videoDeviceInput = nil
                } catch {
                    fatalError()
                }
                self.session!.beginConfiguration()
                self.session!.removeInput(self.videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                self.setCamerasession()
                if self.session!.canAddInput(self.videoDeviceInput) {
                    NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: currentVideoDevice)
                    PFCameraviewcontrollerscreen.setFlashMode(AVCaptureFlashMode.Auto, device: device)
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange: ", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: device)
                    self.session!.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                }else {
                    self.session!.addInput(self.videoDeviceInput)
                }
                self.session!.commitConfiguration()
                self.addCameraDataOutput()
                dispatch_async(dispatch_get_main_queue(), {
                    sender.enabled = true
                    self.activityImageView.hidden = true
                    self.pfcToggleCameraButton.hidden = false
                    self.pfcCameraArrow.hidden = false
                    self.pfCameraStartButton.userInteractionEnabled = true
                    self.pfcToggleCameraButton.userInteractionEnabled = true
                })
                print("CameraScreen pfcp_pcameraselete_action end")
            }
        }
    }

    /**
     Check the flash mode is currently enabled or not.If its enabled turn on flash after commit configuration.
      - parameter sender: flash button on interface.
     */
    @IBAction func pfcFlashButton_action(sender: AnyObject) {
        print("CameraScreen pfcFlashButton_action begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "flashSwitch", value: nil)
        let currentVideoDevice: AVCaptureDevice = self.videoDeviceInput!.device
        let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
        if AVCaptureDevicePosition.Front==currentPosition {
            if self.videoDeviceInput!.device.hasTorch {
                // lock your device for configuration
                do {
                    let lockForConfig = try self.videoDeviceInput!.device.lockForConfiguration()
                    print(lockForConfig)
                } catch {
                    print("Flash lockForConfig failed")
                }
                if self.videoDeviceInput!.device.torchActive {
                    self.videoDeviceInput!.device.torchMode = AVCaptureTorchMode.Off
                }
                self.videoDeviceInput!.device.unlockForConfiguration()
            }}
        else {
            // check if the device has torch
            if self.videoDeviceInput!.device.hasTorch {
                // lock your device for configuration
                do {
                    try self.videoDeviceInput!.device.lockForConfiguration()
                } catch {
                    print("Flash lockForConfig failed")
                }
                // check if your torchMode is on or off. If on turns it off otherwise turns it on
                if self.videoDeviceInput!.device.torchActive {
                    self.videoDeviceInput!.device.torchMode = AVCaptureTorchMode.Off
                } else {
                    // sets the torch intensity to 100%
                    do {
                        let enableTorch = try self.videoDeviceInput!.device.setTorchModeOnWithLevel(1.0)
                    } catch {
                        print("enableTorch failed")
                    }
                    //    self.videoDeviceInput!.setTorchModeOnWithLevel(1.0, error: nil)
                }
                // unlock your device
                self.videoDeviceInput!.device.unlockForConfiguration()
            }
        }
        print("CameraScreen pfcFlashButton_action end")
    }

    /**
     Showing the back button alert view
      - parameter sender: back button from interface
     */
    @IBAction func pfc_camera_previousview(sender: AnyObject) {
        backButtonalertView()
    }
   
    /**
     Delete the previously recorded video from local and updating the interface
      - parameter sender: cancel button from interface
     */

    @IBAction func pfc_camera_cancel(sender: AnyObject) {
        print("CameraScreen pfc_camera_cancel begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "deleteVideo", value: nil)
        if(tagvalue==nil) {
            return
        }
        previewBackground.hidden = true
        pfcCameraBackgroundImageView.hidden = false
        if(tagvalue==420) {
            pfPlaySubView1.hidden=true
            self.pfcPreviewSubmitButton.tag=460
            instructionstring=introVideoInstruction
            pfcCameraBackgroundImageView.image = UIImage(named: "main_bg_layer1.png")
            isFaceorEyeDected = false
            videoCount = 1
            PFGlobalConstants.setResumeVideoCount(videoCount)
            hideDeletePreviousVideoButtonIfResumeCount(videoCount)
            deleteTempVideo(iteminavPlayer3)
            tagvalue=430
//            pfcDeletePreviousVideoButton.hidden = true
            pfCameraSview1.hidden=true
            pfCameraSview2.hidden=true
            pfCameraSview3.hidden=true
            pfCameraSview4.hidden=true
            pfcVideoTitleLabel.text="Introduction Video"
            uploadLabel.text = "Video deleted successfully!"
            NSNotificationCenter.defaultCenter().postNotificationName("showAlert", object: nil)
        }
        else if(tagvalue==430) {
            uploadLabel.text = "No videos to delete"
            NSNotificationCenter.defaultCenter().postNotificationName("showAlert", object: nil)
        }
        else if(tagvalue==421) {
            pfPlaySubView2.hidden=true
            tagvalue=420
            self.pfcPreviewSubmitButton.tag=461
            pfcCameraBackgroundImageView.image = UIImage(named: "main_bg_layer1.png")
            self.pfcCameraInstructionlabel.text=facialVideoInstruction
            instructionstring=facialVideoInstruction
            isFaceorEyeDected = false
            videoCount = 2
            PFGlobalConstants.setResumeVideoCount(videoCount)
            hideDeletePreviousVideoButtonIfResumeCount(videoCount)
            deleteTempVideo(iteminavPlayer4)
            pfCameraSview2.hidden=true
            pfCameraSview3.hidden=true
            pfCameraSview4.hidden=true
            pfcVideoTitleLabel.text="Facial Feature Analysis Video"
            uploadLabel.text = "Video deleted successfully!"
            NSNotificationCenter.defaultCenter().postNotificationName("showAlert", object: nil)
        }
        else if(tagvalue==422) {
            pfPlaySubView3.hidden=true
            tagvalue=421
            self.pfcPreviewSubmitButton.tag=462
            pfcEyeNotDetectedImageView.hidden=true
            pfcEyeDetectedImageView.hidden=true
            self.pfCameraFaceDetectedImageView.hidden=true
            self.pfCameraFaceNotDetectedImageView.hidden=true
            pfcCameraBackgroundImageView.image = UIImage(named: "main_bg_layer1.png")
            isFaceorEyeDected = false
            self.pfcCameraInstructionlabel.text=headVideoInstruction
            instructionstring=headVideoInstruction
            videoCount = 3
            PFGlobalConstants.setResumeVideoCount(videoCount)
            hideDeletePreviousVideoButtonIfResumeCount(videoCount)
            deleteTempVideo(iteminavPlayer5)
            pfCameraSview3.hidden=true
            pfCameraSview4.hidden=true
            pfcVideoTitleLabel.text="Head Feature Analysis Video"
            uploadLabel.text = "Video deleted successfully!"
            NSNotificationCenter.defaultCenter().postNotificationName("showAlert", object: nil)
        }
        else if(tagvalue==423) {
            pfPlaySubView4.hidden=true
            tagvalue=422
            self.pfcPreviewSubmitButton.tag=463
            pfcEyeNotDetectedImageView.hidden=true
            pfcEyeDetectedImageView.hidden=true
            pfcCameraBackgroundImageView.image = UIImage(named: "")
            isFaceorEyeDected = true
            videoCount = 4
            PFGlobalConstants.setResumeVideoCount(videoCount)
            hideDeletePreviousVideoButtonIfResumeCount(videoCount)
            deleteTempVideo(iteminavPlayer6)
            pfCameraSview4.hidden=true
            pfcVideoTitleLabel.text="Eye Feature Analysis Video"
            uploadLabel.text = "Video deleted successfully!"
            NSNotificationCenter.defaultCenter().postNotificationName("showAlert", object: nil)
        }
       print("CameraScreen pfc_camera_cancel end")
    }

    /**
     Playing the recorded video for previewing to the user.
     An observer added for knowing the end of the video if its played and updates the UI.
     - parameter sender: play button from interface
     */

    @IBAction func pfcPreviewPlayButtonaction(sender: AnyObject) {
        print("CameraScreen pfcPreviewPlayButtonaction begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "PlayVideo", value: nil)
        avPlayer.play()
        // hidden
        pfcPreviewRetakeButton.hidden=true
        pfcPreviewSubmitButton.hidden=true
        pfcPreviewPlayButton.hidden=true
        // un hidden
        pfcPreviewPauseButton.hidden=false
        previewBackground.hidden = true
        pfcPreviewSlider.hidden=false
        print("CameraScreen pfcPreviewPlayButtonaction end")
    }

    /**
     Pause action pauses the currently playing video and updates the UI.
      - parameter sender: Pause button on interface.
     */

    @IBAction func pfcPreviewPauseButtonaction(sender: AnyObject) {
        print("CameraScreen pfcPreviewPauseButtonaction begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "PauseVideo", value: nil)
        if !isPreviewScreen
        {
            avPlayer.pause()
            pfcPreviewSlider.hidden=true
            pfcPreviewPauseButton.hidden=true
            //
            pfcPreviewPlayButton.hidden=false
            
            previewBackground.hidden = false
            avPlayer.seekToTime(kCMTimeZero)
        }
        else
        {
            avPlayer.pause()
            pfcPreviewSlider.hidden=true
            pfcPreviewPauseButton.hidden=true
            //
            pfcPreviewPlayButton.hidden=false
            if !isRotationErrorOccured
            {
                pfcPreviewSubmitButton.hidden=false
            }
            pfcPreviewRetakeButton.hidden=false
            previewBackground.hidden = false
            avPlayer.seekToTime(kCMTimeZero)
        }
        print("CameraScreen pfcPreviewPauseButtonaction begin")
    }

    /**
     Detleting the video from the given URL.
      - parameter reqVideoUrl: file will be delted with the given URL
     */

    func deleteTempVideo(reqVideoUrl: NSURL) {
        print("CameraScreen deleteTempVideo begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "deleteLocalVideo", value: nil)
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtURL(reqVideoUrl)
            print("File Deleted.")
        } catch {
            print("Could not clear temp folder: \(error)")
        }
        print("CameraScreen deleteTempVideo end")
    }

    /**
     Submit Action working with the tag value assigned with that submit button.
     Uploading the recorded video to the server and also Updating the UI to take next video.
     Updating the title and instruction label
     - parameter sender: submit button from interface
     */

    @IBAction func pfcPreviewSubmitButtonaction(sender: AnyObject) {
        print("CameraScreen pfcPreviewSubmitButtonaction begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "submitButton", value: videoCount)
        if(self.pfcPreviewSubmitButton.tag != 463)
        {
            self.pfcCameraArrow.hidden = false
            if !isResumeCameraViewEnabled {
                self.backButtonView.hidden = false
            }
            self.previewBackground.hidden = true
            self.previewView.hidden = false
            self.pfInfoselectButton.hidden = false
            let currentVideoDevice: AVCaptureDevice = self.videoDeviceInput!.device
            let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
            switch currentPosition{
            case AVCaptureDevicePosition.Front:
                self.pfcFlashButton.hidden = true
            case AVCaptureDevicePosition.Back:
                self.pfcFlashButton.hidden = false
            case AVCaptureDevicePosition.Unspecified:
                self.pfcFlashButton.hidden = false
            }
            self.uploadLabel.text = "File upload successfully!"
            self.canShowErrorMsg = true
            // remove super layer
            avPlayerLayer.hidden = true
        }
        pfcPreviewSlider.minimumValue = 0.0
        if(self.pfcPreviewSubmitButton.tag==460) {

            pfCameraSview1.hidden=false
            tagvalue = 420
            let iteration = "1"
            videoCount = 2
            PFGlobalConstants.setResumeVideoCount(videoCount)
            setThumbImageFor(videothumbImageView1)
            self.pfcPreviewSubmitButton.tag=461
            // vediou play button of stored vediou
            pfPlaySubView1.hidden=false
            // animate the playbutton
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(M_PI*2)
            let duration = 1.0
            rotateAnimation.duration = duration
            pfPlaySubView1.layer.addAnimation(rotateAnimation, forKey: "myAnimationKey")
            pfcVideoTitleLabel.text="Facial Feature Analysis Video"
            // universal use
            iteminavPlayer3=itemtobeplayed
            self.pfcCameraBackgroundImageView.hidden = false
            pfcFaceAnimationImageView.hidden=true
            self.pfcCameraInstructionlabel.text=facialVideoInstruction
            instructionstring=facialVideoInstruction
//            self.cameraModel!.nextvideo(iteration)
            let mediaAWSURL = self.cameraModel!.uploadPatientMediaToAWS(iteration, patientId: patientID)
            if documentAWSLink != nil {
                self.updatePatientMediaDetailsOnPortal(patientID, mediaURL: documentAWSLink!, isDocument: true, complition: { (isSucceed) in
                    self.updatePatientMediaDetailsOnPortal(self.patientID, mediaURL: mediaAWSURL, isDocument: false, complition: { (isSucceed) in
                        
                    })
                })
            }
            else {
                self.updatePatientMediaDetailsOnPortal(patientID, mediaURL: mediaAWSURL, isDocument: false, complition: { (isSucceed) in
                    
                })
            }

        }
        else if(self.pfcPreviewSubmitButton.tag==461) {

            pfCameraSview2.hidden=false
            let iteration = "2"
            tagvalue = 421
            videoCount = 3
            PFGlobalConstants.setResumeVideoCount(videoCount)
            setThumbImageFor(videothumbImageView2)
            self.pfcPreviewSubmitButton.tag=462
            // vediou play button of stored vediou
            pfPlaySubView2.hidden=false
            // animateing
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(M_PI*2)
            let duration = 1.0
            rotateAnimation.duration = duration
            pfPlaySubView2.layer.addAnimation(rotateAnimation, forKey: "myAnimationKey")
            pfcVideoTitleLabel.text="Head Feature Analysis Video"
            // universal use
            iteminavPlayer4=itemtobeplayed
            pfcFaceAnimationImageView.hidden=true
            self.pfcCameraBackgroundImageView.hidden = false
            self.pfcCameraInstructionlabel.text=headVideoInstruction
            instructionstring=headVideoInstruction
//            self.cameraModel!.nextvideo(iteration)
            let mediaAWSURL = self.cameraModel!.uploadPatientMediaToAWS(iteration, patientId: patientID)
            self.updatePatientMediaDetailsOnPortal(patientID, mediaURL: mediaAWSURL, isDocument: false, complition: { (isSucceed) in
                
            })
        }
        else if(self.pfcPreviewSubmitButton.tag==462) {

            pfCameraSview3.hidden=false
            let iteration = "3"
            tagvalue = 422
//            cameraModel!.nextvideo(iteration)
            videoCount = 4
            PFGlobalConstants.setResumeVideoCount(videoCount)
            setThumbImageFor(videothumbImageView3)
            self.pfcPreviewSubmitButton.tag=463
            // vediou play button of stored vediou
            pfPlaySubView3.hidden=false
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(M_PI*2)
            let duration = 1.0
            rotateAnimation.duration = duration
            pfPlaySubView3.layer.addAnimation(rotateAnimation, forKey: "myAnimationKey")
            // universal use
            iteminavPlayer5=itemtobeplayed
            // isFaceorEyeDected set
            isFaceorEyeDected = true
            // setting background image
            self.pfCameraFaceDetectedImageView.hidden=true
            self.pfCameraFaceNotDetectedImageView.hidden=true
            pfcFaceAnimationImageView.hidden=true
            pfcEyeAnimationImageView.hidden=true
            self.pfcCameraInstructionlabel.text=eyeVideoInstruction
            instructionstring=eyeVideoInstruction
            pfcCameraBackgroundImageView.image = UIImage(named: "")
            self.pfcCameraBackgroundImageView.hidden = false
            isFaceorEyeDected = true
            self.pfCameraFaceDetectedImageView.hidden=true
            self.pfCameraFaceNotDetectedImageView.hidden=true
            self.pfcEyeNotDetectedImageView.hidden = false
            self.pfcEyeDetectedImageView.hidden = false
            pfcFaceAnimationImageView.hidden=true
            pfcVideoTitleLabel.text="Eye Feature Analysis Video"
            let mediaAWSURL = self.cameraModel!.uploadPatientMediaToAWS(iteration, patientId: patientID)
            self.updatePatientMediaDetailsOnPortal(patientID, mediaURL: mediaAWSURL, isDocument: false, complition: { (isSucceed) in
                
            })
        }
        else if(self.pfcPreviewSubmitButton.tag==463) {
            
            self.pfcPreviewSubmitButton.tag = 464
            let iteration = "4"
//            self.cameraModel!.nextvideo(iteration)
            let mediaAWSURL = self.cameraModel!.uploadPatientMediaToAWS(iteration, patientId: patientID)
            
            self.pfCameraSview4.hidden=false
            setThumbImageFor(videothumbImageView4)
            // vediou play button of stored vediou
            self.pfPlaySubView4.hidden=false
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(M_PI*2)
            let duration = 1.0
            rotateAnimation.duration = duration
            self.pfPlaySubView4.layer.addAnimation(rotateAnimation, forKey: "myAnimationKey")
            // universal use
            self.iteminavPlayer6=itemtobeplayed
            
            self.pfcCameraBackgroundImageView.image = UIImage(named: "main_bg_layer1.png")
            self.pfcCameraBackgroundImageView.hidden = false
            
            self.pfcEyeNotDetectedImageView.hidden=true
            self.pfcEyeDetectedImageView.hidden=true
            
            self.pfCameraFaceDetectedImageView.hidden=true
            self.pfCameraFaceNotDetectedImageView.hidden=true
            self.pfcEyeAnimationImageView.hidden=true
            self.isFaceorEyeDected = false
//            self.cameraModel!.updatePatientMediaDetails()
            PFGlobalConstants.removeResumeVideoCount()
            previewView.removeFromSuperview()
            pfcCameraBackgroundImageView.hidden=true
            self.activityImageView.hidden = false
            self.updatePatientMediaDetailsOnPortal(patientID, mediaURL: mediaAWSURL, isDocument: false, complition: { (isSucceed) in
                if self.isResumeCameraViewEnabled == true {
                    self.getResumePatientList({ (isHavingList, patientList) in
                        self.activityImageView.hidden = true
                        dispatch_async(dispatch_get_main_queue(), { 
                            if isHavingList == true {
                                self.session?.stopRunning()
                                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let resumeListView = storyBoard.instantiateViewControllerWithIdentifier("ResumePatientListViewController") as! ResumePatientListViewController
                                resumeListView.patientsArray = patientList
                                resumeListView.delegate = self
                                let nav = UINavigationController(rootViewController: resumeListView)
                                nav.navigationBarHidden = true
                                //                            self.presentViewController(nav, animated: true, completion: nil)
                                UIView.transitionWithView((APP_DELEGATE?.window)!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                                    APP_DELEGATE!.window?.rootViewController = nav
                                }) { (isCompleted) in
                                    self.view = nil
                                }
                            }
                            else {
                                self.session?.stopRunning()
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
                        })
                    })
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.session?.stopRunning()
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PFSinginViewController") as! PFSinginViewController
                        nextViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                        nextViewController.canShowVideoUploadAlert = true
                        let nav = UINavigationController(rootViewController: nextViewController)
                        nav.navigationBarHidden = true
                        let appDelegaet = UIApplication.sharedApplication().delegate as? AppDelegate
                        UIView.transitionWithView((appDelegaet?.window)!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                            appDelegaet!.window?.rootViewController = nav
                        }) { (isCompleted) in
                        }
                    })
                }
            })
            
        }
        if(self.pfcPreviewSubmitButton.tag != 464)
        {
            // preview hidden
            pfcPreviewRetakeButton.hidden=true
            pfcPreviewPlayButton.hidden=true
            pfcPreviewSubmitButton.hidden=true
            // unhidden camera functions
            pfcToggleCameraButton.hidden=false
            // acleometer unhidden
            pfcAcleometer.hidden=false
            contentView.hidden=false
            accelerometerView.hidden = false
            if !qualityCheck {
                pfCameraStartButton.hidden = false
                self.pfCameraStartButton.userInteractionEnabled = true
            }
            // cancel unhidden
//            pfcDeletePreviousVideoButton.hidden=false
            pfcBackButton.hidden=false
            isPreviewScreen = false
            // instruction label hidden
            pfcCameraInstructionlabel.hidden=false
            pfcVideoTitleLabel.hidden=false
            if !qualityCheck {
                pfCameraStartButton.hidden = false
                self.pfCameraStartButton.userInteractionEnabled = true
            }
        }
       print("CameraScreen pfcPreviewSubmitButtonaction end")
    }

    /**
     Presenting the AVPlayer for showing the demo video to the user.
     Demo video will be displayed respect with user currently recording video count.
      - parameter sender: info button on interface
     */
    
    @IBAction func PFC_infoaction(sender: AnyObject) {
        print("CameraScreen PFC_infoaction begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "PlayInfoVideo", value: videoCount)
        if !isPreviewScreen
        {
            // preview hidden
            self.pfcPreviewRetakeButton.hidden=true
            self.pfcPreviewPlayButton.hidden=false
            self.pfcPreviewSubmitButton.hidden=true
//            self.pfcDeletePreviousVideoButton.hidden = true
            // hidden camera functions
            self.pfcToggleCameraButton.hidden=true
            // acleometer hidden
            self.pfcAcleometer.hidden=true
            self.contentView.hidden=true
            accelerometerView.hidden = true
            self.pfCameraStartButton.hidden = true
            // animation hidden
            self.pfcFaceAnimationImageView.hidden=true
            self.pfcEyeAnimationImageView.hidden=true
            self.pfcCameraInstructionlabel.hidden=true
            // disable the button
            self.backButtonView.hidden = true
            self.pfcFlashButton.hidden = true
            self.canShowErrorMsg = false
            self.pfCameraStop.hidden=true
            self.counterview.hidden = true
            if videoCount == 1 {
                self.pfcCameraCountdownLabel.text = "5"
            }
            else {
                self.pfcCameraCountdownLabel.text = "15"
            }
            self.pfCameraFaceDetectedImageView.hidden=true
            self.pfCameraFaceNotDetectedImageView.hidden=true
            self.pfcEyeNotDetectedImageView.hidden=true
            self.pfcEyeDetectedImageView.hidden=true
            self.pfcCameraArrow.hidden = true
            self.previewBackground.hidden = true
            self.pfInfoselectButton.hidden = true
            self.pfcCameraBackgroundImageView.hidden = true
            self.startButtonBackgroundImageView.hidden = true
            self.videoThumbView.hidden = true
        }
        closeInfoVideoButton.hidden = false
        self.pfcVideoTitleLabel.hidden = true
        var path2: String!
        if videoCount == 1 {
            path2 = NSBundle.mainBundle().pathForResource("video1", ofType: "mp4")!
        }
        if videoCount == 2 {
            path2 = NSBundle.mainBundle().pathForResource("video2", ofType: "mp4")!
        }
        if videoCount == 3 {
            path2 = NSBundle.mainBundle().pathForResource("video3", ofType: "mp4")!
        }
        if videoCount == 4 {
            path2 = NSBundle.mainBundle().pathForResource("video4", ofType: "mp4")!
        }
        let url = NSURL.fileURLWithPath(path2)
        playItemWithURL(url)
        print("CameraScreen PFC_infoaction end")
    }

    
    /**
     Checking the Device Authorization Status for application had the permission to access the camera
     */

    func checkDeviceAuthorizationStatus() {
        let mediaType: String = AVMediaTypeVideo
        AVCaptureDevice.requestAccessForMediaType(mediaType, completionHandler: { (granted: Bool) in
            if granted{
                self.deviceAuthorized = true
            }else {
                    dispatch_async(dispatch_get_main_queue(), {
                    let alert: UIAlertController = UIAlertController(
                        title: "Warning",
                        message: "PhiFactor does not have permission to access camera",
                        preferredStyle: UIAlertControllerStyle.Alert)
                            let action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                        (action2: UIAlertAction) in
                        exit(0)
                    })
                            alert.addAction(action)
                            self.presentViewController(alert, animated: true, completion: nil)
                })
                    self.deviceAuthorized = false
            }
        })
    }

    /**
     Getting the AVCaptureDevice instance with the given mediaType and prefered position
      - parameter mediaType:         requesting the capture device with this mediatype
     - parameter preferringPosition: requesting the capture position is front or rear
      - returns: AVCapture device with the provided mediaType and prefered position
     */

    class func deviceWithMediaType(mediaType: String, preferringPosition: AVCaptureDevicePosition)->AVCaptureDevice{
        var devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var captureDevice: AVCaptureDevice = devices[0] as! AVCaptureDevice
        for device in devices{
            if device.position == preferringPosition{
                captureDevice = device as! AVCaptureDevice
                do {
                    try captureDevice.lockForConfiguration()
                    captureDevice.automaticallyAdjustsVideoHDREnabled = true
                    captureDevice.unlockForConfiguration()
                }
                catch {
                    print("Enabling HDR failed")
                }
                if captureDevice.isFocusModeSupported(.ContinuousAutoFocus) {
                    do {
                        try captureDevice.lockForConfiguration()
                        captureDevice.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                        captureDevice.unlockForConfiguration()
                    }
                    catch {
                        print("Enabling Auto focus failed")
                    }
                }
                if captureDevice.smoothAutoFocusSupported {
                    do {
                        try captureDevice.lockForConfiguration()
                        captureDevice.smoothAutoFocusEnabled = true
                        captureDevice.unlockForConfiguration()
                    }
                    catch {
                        print("Enabling Auto focus failed")
                    }
                }
                //                captureDevice.automaticallyAdjustsVideoHDREnabled = true
                break
            }
        }
        return captureDevice
    }

    /**
     Enabling or Disabling the flash for given AVCapture device
      - parameter flashMode: On or OFF
     - parameter device:   Flash mode assigned for the given device
     */

    class func setFlashMode(flashMode: AVCaptureFlashMode, device: AVCaptureDevice) {
        if device.hasFlash && device.isFlashModeSupported(flashMode) {
            var error: NSError? = nil
            do {
                try device.lockForConfiguration()
                device.flashMode = flashMode
                device.unlockForConfiguration()
                } catch let error1 as NSError {
                error = error1
                print(error)
            }
        }
    }

    // MARK: Actions

    func playerItemDidReachEnd(notification: NSNotification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        avPlayer.pause()
        p.seekToTime(kCMTimeZero)
    }

    /**
     Restarting the demo video after complition of video playing.
     */
    
    func restartdemoVideoFromBeginning()  {
        let seconds: Int64 = 0
        let preferredTimeScale: Int32 = 1
        let seekTime: CMTime = CMTimeMake(seconds, preferredTimeScale)
//        avPlayer1.seekToTime(seekTime)
//        avPlayer1.pause()
        PFSHbackrongimage.hidden=false
        pauseaction.hidden=true
        stopdemovedio.hidden=false
    }

    // record complete

    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if(error != nil) {
            print(error)
        }
        print("CameraScreen didFinishRecordingToOutputFileAtURL begin")
        PFGlobalConstants.sendEventWithCatogory("background", action: "delegate", label: "didFinishRecordingToOutputFileAtURL", value: nil)
        let backgroundRecordId: UIBackgroundTaskIdentifier = self.backgroundRecordId
        self.backgroundRecordId = UIBackgroundTaskInvalid
        if isRotationErrorOccured {
            retakeButtonalertView()
            self.removeMovieDataAndAddCameraDataOuput()
        }
        else {
            //play the preview vedio
            itemtobeplayed=outputFileURL
            self.pfcCameraInstructionlabel.hidden=true
            self.previewView.hidden = true
            
            dispatch_async(dispatch_get_main_queue(), {
                self.myTimer.invalidate()
                self.pfcCameraArrow.hidden = true

                UIView.transitionWithView((self.videoPreviewView)!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    self.playItemWithURL(itemtobeplayed)
                }) { (isCompleted) in
                    
                }
                // preview hidden
                self.pfcPreviewRetakeButton.hidden=false
                self.pfcPreviewPlayButton.hidden=false
                self.pfcPreviewSubmitButton.hidden=true
//                self.pfcDeletePreviousVideoButton.hidden = true
                // hidden camera functions
                self.pfcToggleCameraButton.hidden=true
                // acleometer hidden
                self.pfcAcleometer.hidden=true
                self.contentView.hidden=true
                self.accelerometerView.hidden = true
                self.pfCameraStartButton.hidden = true
                // animation hidden
                self.pfcFaceAnimationImageView.hidden=true
                self.pfcEyeAnimationImageView.hidden=true
                // instruction label hidden and heading label
                // pfcVideoTitleLabel.hidden=true
                self.pfcCameraInstructionlabel.hidden=true
                // disable the button
                self.isPreviewScreen = true
                self.backButtonView.hidden = true
                self.pfcFlashButton.hidden = true
                self.canShowErrorMsg = false
                self.pfCameraStop.hidden=true
                self.counterview.hidden = true
                self.pfcCameraCountdownLabel.text = "15"
                self.pfCameraFaceDetectedImageView.hidden=true
                self.pfCameraFaceNotDetectedImageView.hidden=true
                self.pfcEyeNotDetectedImageView.hidden=true
                self.pfcEyeDetectedImageView.hidden=true
                
                self.removeMovieDataAndAddCameraDataOuput()
                
                self.previewBackground.hidden = false
                self.pfcCameraBackgroundImageView.hidden = true
                print("CameraScreen didFinishRecordingToOutputFileAtURL end")
            })
        }
       
    }

    // MARK: Selector
   
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
        self.focusWithMode(AVCaptureFocusMode.ContinuousAutoFocus, exposureMode: AVCaptureExposureMode.ContinuousAutoExposure, point: devicePoint, monitorSubjectAreaChange: false)
    }

    // MARK: Custom Function

    func focusWithMode(focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode, point: CGPoint, monitorSubjectAreaChange: Bool) {
        dispatch_async(self.sessionQueue, {
            let device: AVCaptureDevice! = self.videoDeviceInput!.device
            do {
                try device.lockForConfiguration()
                    if device.focusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusMode = focusMode
                    device.focusPointOfInterest = point
                }
                if device.exposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = point
                    device.exposureMode = exposureMode
                }
                device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
                }catch{
                print(error)
            }
        })
    }

    /**
     Showing the alert from the top and automatically close after 2 seconds.
     */

    func showAlertandDelete() {
        let tempStr = self.uploadLabel.text
        if isDocumentAlert == true {
            self.uploadLabel.text = documentUploadingAlertText
        }
        dispatch_async(dispatch_get_main_queue()) {
            var uploadframe: CGRect!
            uploadframe=self.uploadstatus.frame
            uploadframe.origin.x=self.view.frame.origin.x
            uploadframe.size.width=self.view.frame.size.width
            uploadframe.size.height=100
            uploadframe.origin.y=self.view.frame.origin.y-50
            self.uploadstatus.frame=uploadframe
            self.view.addSubview(self.uploadstatus)
            var setresize: CGRect!
            setresize=self.uploadstatus.frame
            setresize.origin.x=self.uploadstatus.frame.origin.x
            setresize.origin.y=0
            setresize.size.width=self.view.frame.size.width
            setresize.size.height=100
            UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.uploadstatus.frame=setresize
                }, completion: nil)
            var setresizenormal: CGRect!
            setresizenormal=self.uploadstatus.frame
            setresizenormal.origin.x=self.uploadstatus.frame.origin.x
            setresizenormal.origin.y=0-self.uploadstatus.frame.size.height
            setresizenormal.size.width=self.view.frame.size.width
            setresizenormal.size.height=100
            UIView.animateWithDuration(0.30, delay: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:  {
                self.uploadstatus.frame=setresizenormal
                }, completion: { (completed) in
                    if self.isDocumentAlert == true {
                        self.uploadLabel.text = tempStr
                        self.isDocumentAlert = false
                    }
            })
        }
        
    }

    /**
     Initiate the accelerometer.
     Updating the UI with the value from accelerometer delegate.
     If the accelerometer range within 2 or -2 degree showing the green overlay. Otherwise red overlay updated.
      - returns: void
     */

    func initAccelometer() {
        PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "initAccelometer", value: nil)
        contentView.layer.cornerRadius = contentView.frame.width/2-30
        contentView.layer.masksToBounds = true
        greenCircleView.layer.cornerRadius = greenCircleView.frame.width/2-30
        
        print(greenCircleView.frame.width/2)
        greenCircleView.layer.masksToBounds = true
        self.view.layer.masksToBounds = true
        motionManager = CMMotionManager()
        if (motionManager.accelerometerAvailable) {
            greenCircleView.hidden = true
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMAccelerometerData?, error: NSError?) in
                if (self != nil) {
                    if let acceleration = data?.acceleration {
                        self?.greenCircleView.hidden = false
                        var rotation = 0.0
                        if acceleration.z >= 0 {
                            let topCenter: CGPoint = CGPointMake(ceil(((CGFloat(acceleration.x) * -(self!.contentView.frame.width/2)) + (self!.contentView.frame.width/2))), ceil((CGFloat(acceleration.y) * -(self!.contentView.frame.height/2) + (CGFloat(acceleration.z) * (self!.contentView.frame.height)))))
                            self!.greenCircleView.layer.position = topCenter
                            self?.accelerometerBGImageView.layer.position = topCenter
                        }
                        else {
                            let topCenter: CGPoint = CGPointMake(ceil(((CGFloat(acceleration.x) * -(self!.contentView.frame.width/2)) + (self!.contentView.frame.width/2))), ceil((CGFloat(acceleration.y) * -(self!.contentView.frame.height/2))))
                            self!.greenCircleView.layer.position = topCenter
                            self?.accelerometerBGImageView.layer.position = topCenter
                        }
                        rotation = atan2(acceleration.x, acceleration.y)
                        let degree = rotation.radiansToDegrees
                        var convertedDegree  = 0.0
                        if degree > 0 {
                            convertedDegree  = 90 - degree
                        }
                        else {
                            convertedDegree  = 90 + degree
                        }
                        if acceleration.z >= 0 {
                            convertedDegree = acceleration.z * 100
                        }
                        else {
                            convertedDegree = 100 + (acceleration.y * 100)
                        }
                        if convertedDegree == 0 {
                            self!.canStartRecording = true
                            self!.labelAxisY.text = String(format: "%i\u{00B0}", Int(convertedDegree))
                            if self!.greenCircleView.backgroundColor != UIColor.greenColor() {
                                UIView.animateWithDuration(1.0, animations: {
                                    self!.greenCircleView.backgroundColor = UIColor.greenColor()
                                    self?.accelerometerBGImageView.image = UIImage(named: "circle_icon3.png")
                                    self!.pfcCameraInstructionlabel.text="Patient states name and clinic."
                                })
                                if(self!.isFaceorEyeDected==true) {
                                    self!.pfCameraFaceDetectedImageView.hidden=true
                                    self!.pfCameraFaceNotDetectedImageView.hidden=true
                                    self!.pfcEyeNotDetectedImageView.hidden=false
                                    self!.pfcEyeDetectedImageView.hidden=true
                                }
                                else {
                                    self!.pfCameraFaceDetectedImageView.hidden=false
                                    self!.pfCameraFaceNotDetectedImageView.hidden=true
                                }
                                if(self!.isPreviewScreen==true) {
                                    self!.pfCameraFaceDetectedImageView.hidden=true
                                    self!.pfCameraFaceNotDetectedImageView.hidden=true
                                    self!.pfcEyeNotDetectedImageView.hidden=true
                                    self!.pfcEyeDetectedImageView.hidden=true
                                }
                                else {
                                }
                                self!.pfcCameraInstructionlabel.text=self!.instructionstring
                            }
                        }
                        else if convertedDegree < 6.0 && convertedDegree > -6.0 {
                            self!.canStartRecording = true
                            self!.labelAxisY.text = String(format: "%i\u{00B0}", Int(convertedDegree))
                            if self!.greenCircleView.backgroundColor != UIColor.greenColor() {
                                UIView.animateWithDuration(1.0, animations: {
                                    self!.greenCircleView.backgroundColor = UIColor.greenColor()
                                    self?.accelerometerBGImageView.image = UIImage(named: "circle_icon3.png")
                                    if(self!.isFaceorEyeDected==true) {
                                        self!.pfCameraFaceDetectedImageView.hidden=true
                                        self!.pfCameraFaceNotDetectedImageView.hidden=true
                                        self!.pfcEyeNotDetectedImageView.hidden=false
                                        self!.pfcEyeDetectedImageView.hidden=true
                                    }
                                    else {
                                        self!.pfCameraFaceDetectedImageView.hidden=false
                                        self!.pfCameraFaceNotDetectedImageView.hidden=true
                                    }
                                    if(self!.isPreviewScreen==true) {
                                        self!.pfCameraFaceDetectedImageView.hidden=true
                                        self!.pfCameraFaceNotDetectedImageView.hidden=true
                                        self!.pfcEyeNotDetectedImageView.hidden=true
                                        self!.pfcEyeDetectedImageView.hidden=true
                                    }
                                    else {
                                    }
                                    self!.pfcCameraInstructionlabel.text=self!.instructionstring
                                })
                            }
                        }
                        else {
                            self!.canStartRecording = false
                            self!.labelAxisY.text = String(format: "-%i\u{00B0}", Int(convertedDegree)).stringByReplacingOccurrencesOfString("--", withString: "-")
                            if self?.movieFileOutput?.recording == true
                            {
                                self!.isRotationErrorOccured = true
                                self!.pfCameraStopaction(self!)
                            }
                            if self!.greenCircleView.backgroundColor != UIColor.redColor() {
                                if (self?.movieFileOutput?.recording == true) {
                                    self?.showErrorMessage("Don't tilt the device")
                                }
                                else {
                                }
                                UIView.animateWithDuration(1.0, animations: {
                                    self!.greenCircleView.backgroundColor = UIColor.redColor()
                                    self?.accelerometerBGImageView.image = UIImage(named: "circle_icon2.png")
                                    if(self!.isFaceorEyeDected==true) {
                                        self!.pfCameraFaceDetectedImageView.hidden=true
                                        self!.pfCameraFaceNotDetectedImageView.hidden=true
                                        self!.pfcEyeNotDetectedImageView.hidden=true
                                        self!.pfcEyeDetectedImageView.hidden=false
                                    }
                                    else {
                                        self!.pfCameraFaceDetectedImageView.hidden=true
                                        self!.pfCameraFaceNotDetectedImageView.hidden=false
                                    }
                                    if(self!.isPreviewScreen==true) {
                                        self!.pfCameraFaceDetectedImageView.hidden=true
                                        self!.pfCameraFaceNotDetectedImageView.hidden=true
                                        self!.pfcEyeNotDetectedImageView.hidden=true
                                        self!.pfcEyeDetectedImageView.hidden=true
                                    }
                                    else {
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     Updating the video recording interface by count down timer check.
     */
    
    func update() {
        if(count > 0) {
            count -= 01
            pfcCameraCountdownLabel.text = String(count)
            let animation: CATransition = CATransition()
            animation.duration = 0.50
            animation.type = kCATransitionFade
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pfcCameraCountdownLabel.layer.addAnimation(animation, forKey: "changeTextTransition")
            if(isFaceorEyeDected==false) {
                pfcFaceAnimationImageView.startAnimating()
            }
            else {
                pfcEyeAnimationImageView.startAnimating()
            }
        }
        else {
            pfCameraStopaction(self)
        }
    }
    
    /**
     Updating the slider respect with the current info video duration.
     */
    
    func updateSliderInfo() {

        totalDuration = Float( CMTimeGetSeconds(duration))
        slider.value = currentTime // Setting slider value as current time
        slider.maximumValue = totalDuration //Setting maximum value as total duration of the video
    }
    
    /**
     Seeking the info video time respect with the slider value change.
     
     - parameter sender: video slider from interface.
     */
    
    func sliderValueDidChangeInfo(sender: UISlider!) {
        timeInSecond=slider.value
        newtime = CMTimeMakeWithSeconds(Double(timeInSecond), 1);//Setting new time using slider value
    }

    /**
     Updating the slider respect with the current preview video duration.
     */
    
    func updateSlider() {
        if avPlayer.currentItem != nil
        {
            floatTime = Float(CMTimeGetSeconds(avPlayer.currentTime()))
            duration = avPlayer.currentItem!.asset.duration
            let floatTime1 = Float( CMTimeGetSeconds(duration))
            
            pfcPreviewSlider.value = floatTime
            
            pfcPreviewSlider.maximumValue = floatTime1
        }
    }

    /**
     Seeking the preview video time respect with the slider value change.
     
     - parameter sender: video slider from interface.
     */
    
    func sliderValueDidChange(sender: UISlider!)
    {
        timeInSecond=pfcPreviewSlider.value
        newtime = CMTimeMakeWithSeconds(Double(timeInSecond), 1)
        avPlayer.seekToTime(newtime)
    }

    /**
     Showing the confirmation alert from top while back button is pressed for exit the current session or not.
     */
    func backButtonalertView() {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        backButtonAlertView.frame.size.width=self.view.frame.size.width
        backButtonAlertView.frame.size.height=self.view.frame.size.height
        backButtonAlertView.frame.origin.x=0
        backButtonAlertView.frame.origin.y=self.view.frame.size.height
        self.view.addSubview(backButtonAlertView)
        var setframe=backButtonAlertView.frame
        setframe.size.width=backButtonAlertView.frame.size.width
        setframe.size.height=backButtonAlertView.frame.size.height
        setframe.origin.y=0
        setframe.origin.x=0
        UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.TransitionCurlUp, animations: {
            self.backButtonAlertView.frame=setframe
            }, completion: nil)
        pfcVideoTitleLabel.hidden=true
    }

    /**
     Back button alert OK button action which navigates to root viewcontroller.
     */
    @IBAction func backButtonAlertOk() {
        self.session?.stopRunning()
        dispatch_async(dispatch_get_main_queue()) {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        pfcVideoTitleLabel.hidden=false
    }

    /**
     Back button alert Cancel button action which closes the confirmation alert was already shown.
     */
    @IBAction func backButtonCancel() {
        var setresizenormal: CGRect!
        setresizenormal=self.backButtonAlertView.frame
        setresizenormal.origin.x=self.backButtonAlertView.frame.origin.x
        setresizenormal.origin.y=self.backButtonAlertView.frame.size.height
        setresizenormal.size.width=self.view.frame.size.width
        setresizenormal.size.height=self.backButtonAlertView.frame.size.height
        UIView.animateWithDuration(0.30, delay: 0, options: .CurveEaseInOut, animations: { 
            self.backButtonAlertView.frame=setresizenormal
            }) { (completed) in
                self.blurEffectView.removeFromSuperview()
        }
        pfcVideoTitleLabel.hidden=false
    }
    /**
     Network alert action which alert the user for no internet connection and closes the confirmation alert when user pressed close button.
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
        pfcVideoTitleLabel.hidden=true
    }
    /**
     Close button action hides athe network alert with animation.
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
        pfcVideoTitleLabel.hidden=false
        if netwrkAlertLabel.text == battryAlertText
        {
            canShowBatteryAlert = false
        }
    }
    /**
     Stop the video at the end of video and updating the interface.
     */
    func pfCameraStopthevedio() {
        if !isPreviewScreen
        {
            avPlayer.pause()
            pfcPreviewSlider.hidden=true
            pfcPreviewPauseButton.hidden=true
            //
            pfcPreviewPlayButton.hidden=false
            
            previewBackground.hidden = false
            avPlayer.seekToTime(kCMTimeZero)
        }
        else
        {
            avPlayer.pause()
            pfcPreviewSlider.hidden=true
            pfcPreviewPauseButton.hidden=true
            //
            pfcPreviewPlayButton.hidden=false
            if !isRotationErrorOccured
            {
                pfcPreviewSubmitButton.hidden=false
            }
            pfcPreviewRetakeButton.hidden=false
            previewBackground.hidden = false
            avPlayer.seekToTime(kCMTimeZero)
        }
        
    }
    /**
     Pause the help video while its playing.
     
     - parameter sender: Pause button from the interface.
     */
    
    @IBAction func pausesbuttonaction(sender: AnyObject) {
        pauseaction.hidden=true
        stopdemovedio.hidden=false
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

    /**
     Showing the confirmation alert from top while back button is pressed for exit the current session or not.
     */
    func retakeButtonalertView() {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        //        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        retakeButtonAlertView.frame.size.width=self.view.frame.size.width
        retakeButtonAlertView.frame.size.height=self.view.frame.size.height
        retakeButtonAlertView.frame.origin.x=0
        retakeButtonAlertView.frame.origin.y=self.view.frame.size.height
        self.view.addSubview(retakeButtonAlertView)
        var setframe=retakeButtonAlertView.frame
        setframe.size.width=retakeButtonAlertView.frame.size.width
        setframe.size.height=retakeButtonAlertView.frame.size.height
        setframe.origin.y=0
        setframe.origin.x=0
        UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.TransitionCurlUp, animations: {
            self.retakeButtonAlertView.frame=setframe
            }, completion: nil)
    }
    
    /**
     Back button alert OK button action which navigates to root viewcontroller.
     */
    @IBAction func retakeButtonAlertOk() {
        var setresizenormal: CGRect!
        setresizenormal=self.retakeButtonAlertView.frame
        setresizenormal.origin.x=self.retakeButtonAlertView.frame.origin.x
        setresizenormal.origin.y=self.retakeButtonAlertView.frame.size.height
        setresizenormal.size.width=self.view.frame.size.width
        setresizenormal.size.height=self.retakeButtonAlertView.frame.size.height
        UIView.animateWithDuration(0.30, delay: 0, options: .CurveEaseInOut, animations: {
            self.retakeButtonAlertView.frame=setresizenormal
        }) { (completed) in
            self.blurEffectView.removeFromSuperview()
            if !self.isResumeCameraViewEnabled {
                self.backButtonView.hidden = false
            }
            self.pfcCameraArrow.hidden = false
            self.pfcToggleCameraButton.hidden = false
            self.pfInfoselectButton.hidden = false
            if self.videoCount != 1
            {
//                self.pfcDeletePreviousVideoButton.hidden = false
                self.hideDeletePreviousVideoButtonIfResumeCount(self.videoCount)
            }
            if !self.qualityCheck
            {
                self.pfCameraStartButton.hidden = false
                self.pfCameraStartButton.userInteractionEnabled = true
            }
        }
    }
    
    func batteryStatusCheck() {
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        let batterylevel = UIDevice.currentDevice().batteryLevel * 100
        if batterylevel <= 40 && isBatteryAlertShowing == false && canShowBatteryAlert == true
        {
            netwrkAlertLabel.text = battryAlertText
            networkAlertViewAction()
            isBatteryAlertShowing = true
        }
        
    }
    
    func setThumbImageFor(imageView : UIImageView)
    {
        imageView.image = self.getThumbnailFromVideo(itemtobeplayed)
    }
    func getThumbnailFromVideo(url : NSURL) -> UIImage? {
        let asset = AVURLAsset(URL: url, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        do
        {
            let cgImage = try imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil)
            var uiImage = UIImage(CGImage: cgImage)
            uiImage = uiImage.imageRotatedByDegrees(90, flip: false)
            return uiImage
        }
        catch
        {
            return nil
        }
        // !! check the error before proceeding
        
    }
    
    func playItemWithURL(url : NSURL) {
        PFGlobalConstants.sendEventWithCatogory("background", action: "funCall", label: "PlayAVPlayer", value: nil)
        self.avAsset = AVAsset(URL: url)
        self.avPlayerItem = AVPlayerItem(asset: self.avAsset)
        self.avPlayer.replaceCurrentItemWithPlayerItem(self.avPlayerItem)
        self.avPlayer.seekToTime(kCMTimeZero)
        self.avPlayerLayer.hidden = false

    }
    
    func updateViewForResumeAction()
    {
        backButtonView.hidden = true
        let resumeCount = NSUserDefaults.standardUserDefaults().integerForKey(PFResumeVideoCount)
        if resumeCount != 0 {
            resumeVideoCount = resumeCount
            switch resumeCount {
            case 1:
                break
            case 2:
                pfCameraSview1.hidden=true
                tagvalue = 420
                videoCount = 2
                self.pfcPreviewSubmitButton.tag=461
                // vediou play button of stored vediou
                pfPlaySubView1.hidden=true
                
                pfcVideoTitleLabel.text="Facial Feature Analysis Video"
                // universal use
                self.pfcCameraBackgroundImageView.hidden = false
                pfcFaceAnimationImageView.hidden=true
                self.pfcCameraInstructionlabel.text=facialVideoInstruction
                instructionstring=facialVideoInstruction
                break
            case 3:
                pfCameraSview1.hidden=true
                pfCameraSview2.hidden=true
                tagvalue = 421
                videoCount = 3
                self.pfcPreviewSubmitButton.tag=462
                // vediou play button of stored vediou
                pfPlaySubView2.hidden=true
                
                pfcVideoTitleLabel.text="Head Feature Analysis Video"
                // universal use
                pfcFaceAnimationImageView.hidden=true
                self.pfcCameraBackgroundImageView.hidden = false
                self.pfcCameraInstructionlabel.text=headVideoInstruction
                instructionstring=headVideoInstruction
                break
            case 4:
                pfCameraSview3.hidden=true
                tagvalue = 422
                videoCount = 4
                self.pfcPreviewSubmitButton.tag=463
                // vediou play button of stored vediou
                pfPlaySubView3.hidden=true
            
                // isFaceorEyeDected set
                isFaceorEyeDected = true
                // setting background image
                self.pfCameraFaceDetectedImageView.hidden=true
                self.pfCameraFaceNotDetectedImageView.hidden=true
                pfcFaceAnimationImageView.hidden=true
                pfcEyeAnimationImageView.hidden=true
                self.pfcCameraInstructionlabel.text=eyeVideoInstruction
                instructionstring=eyeVideoInstruction
                pfcCameraBackgroundImageView.image = UIImage(named: "")
                self.pfcCameraBackgroundImageView.hidden = false
                self.pfcEyeDetectedImageView.hidden = false
                self.pfcEyeNotDetectedImageView.hidden = false
                pfcVideoTitleLabel.text="Eye Feature Analysis Video"
                break
            default:
                break
            }
        }
    }
    func hideDeletePreviousVideoButtonIfResumeCount(count: Int){
        if isResumeCameraViewEnabled == true && resumeVideoCount != nil && resumeVideoCount == count{
//            self.pfcDeletePreviousVideoButton.hidden = true
        }
    }
    func remainingTime(time: String) {
        if !isShowingAlert {
            self.uploadLabel.text = time
            var uploadframe: CGRect!
            uploadframe=uploadstatus.frame
            uploadframe.origin.x=self.view.frame.origin.x
            uploadframe.size.width=self.view.frame.size.width
            uploadframe.size.height=100
            uploadframe.origin.y=self.view.frame.origin.y-50
            self.uploadstatus.frame=uploadframe
            self.view.addSubview(uploadstatus)
            self.uploadLabel.text = time
            var setresize: CGRect!
            setresize=self.uploadstatus.frame
            setresize.origin.x=self.uploadstatus.frame.origin.x
            setresize.origin.y=0
            setresize.size.width=self.view.frame.size.width
            setresize.size.height=100
            isShowingAlert = true
            
            UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.uploadstatus.frame=setresize
                }, completion: nil)
        }
        else {
            self.uploadLabel.text = time
        }
        
    }
    func hideInactiveAlert() {
        var setresizenormal: CGRect!
        setresizenormal=self.uploadstatus.frame
        setresizenormal.origin.x=self.uploadstatus.frame.origin.x
        setresizenormal.origin.y=0-self.uploadstatus.frame.size.height
        setresizenormal.size.width=self.view.frame.size.width
        setresizenormal.size.height=100
        UIView.animateWithDuration(0.30, delay: 3.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.uploadstatus.frame=setresizenormal
        }) { (completed) in
            self.isShowingAlert = false
        }
    }
    
    /**
     Update patient media details to portal.
     */
    func updatePatientMediaDetailsOnPortal(patientId: String, mediaURL: String, isDocument: Bool, complition: (isSucceed: Bool)->()) {
        print("PatientScreen getRefreshToken begin")
        let defaults = NSUserDefaults.standardUserDefaults()
        var access_token: String!
        var token_type: String!
        access_token = defaults.stringForKey("access_token")
        token_type = defaults.stringForKey("token_type")
        PFGlobalConstants.sendEventWithCatogory("background", action: "functionCall", label: "updatePatientMediaDetailsOnPortal", value: nil)
        requestString = "\(baseURL)/add_patient_video?Authorization=\(token_type)&access_token=\(access_token)"
        print(requestString)
        url1 = NSURL(string: requestString as String)!
        urlRequest = NSMutableURLRequest(URL: url1)
        urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        cameraModel!.getRequestParameterForAddPatientMediaDetails(patientId, mediaURL: mediaURL, isDocument: isDocument)
        Alamofire.request(urlRequest)
            .responseJSON { response in
                switch response.result {
                case .Failure( let error):
                    print(error)
                    complition(isSucceed: false)
                case .Success(let responseObject):
                    print(responseObject)
                    complition(isSucceed: true)
//                    let response = responseObject as! NSDictionary
                }
                print("PatientScreen getRefreshToken end")
        }
    }
    
    func resumePatientStatus(status: Bool, patientDetails: NSDictionary?) {
        if  status == true {
            self.dismissViewControllerAnimated(true, completion: {
                NSUserDefaults.standardUserDefaults().setObject((patientDetails?.objectForKey("patient_id")), forKey: "patient_id")
                NSUserDefaults.standardUserDefaults().setObject((patientDetails?.objectForKey("patient_id")), forKey: PFPatientIDOnDB)
                PFGlobalConstants.setResumeVideoCount(Int((patientDetails?.objectForKey("resume_video"))! as! NSNumber))
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
        else {
            self.dismissViewControllerAnimated(true, completion: {
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
            })
        }
    }
    
    /**
     Get resume patient list.
     */
    func getResumePatientList(complition:(isHavingList: Bool, patientList: NSArray?)->()) {
        print("PatientScreen getResumePatientList begin")
        let defaults = NSUserDefaults.standardUserDefaults()
        var access_token: String!
        var token_type: String!
        access_token = defaults.stringForKey("access_token")
        token_type = defaults.stringForKey("token_type")
        PFGlobalConstants.sendEventWithCatogory("background", action: "functionCall", label: "updatePatientMediaDetailsOnPortal", value: nil)
        requestString = "\(baseURL)/get_resume_patient_list?Authorization=\(token_type)&access_token=\(access_token)"
        print(requestString)
        url1 = NSURL(string: requestString as String)!
        urlRequest = NSMutableURLRequest(URL: url1)
        urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        cameraModel!.getRequestParameterToGetResumePatientList(user)
        Alamofire.request(urlRequest)
            .responseJSON { response in
                switch response.result {
                case .Failure( let error):
                    print(error)
                case .Success(let responseObject):
                    print(responseObject)
                    if responseObject is NSDictionary {
                        if let status = responseObject.objectForKey("status") as? String {
                            if status == "Success" {
                                if let patientList = responseObject.objectForKey("patients") as? NSArray {
                                    if patientList.count != 0 {
                                        complition(isHavingList: true, patientList: patientList)
                                    }
                                    else {
                                        complition(isHavingList: false, patientList: nil)
                                    }
                                }
                                else {
                                    complition(isHavingList: false, patientList: nil)
                                }
                            }
                            else {
                                complition(isHavingList: false, patientList: nil)
                            }
                        }
                        else {
                            complition(isHavingList: false, patientList: nil)
                        }
                    }
                    else {
                        complition(isHavingList: false, patientList: nil)
                    }
                }
                print("PatientScreen getRefreshToken end")
        }
    }
}

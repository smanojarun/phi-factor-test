//
//  VideoPreviewView.swift
//  PhiFactor
//
//  Created by Apple on 22/07/16.
//  Copyright © 2016 Hubino. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPreviewView: GAITrackedViewController {

    @IBOutlet var videoPreviewLayer: UIView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var closeViewButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var slider: UISlider!
    var avPlayer : AVPlayer!
    var avPlayerLayer : AVPlayerLayer!
    var itemUrl : NSURL!
    var currentTime: Float!
    var totalDuration: Float!
    var duration: CMTime!
    var timeInSecond: Float!
    var newtime: CMTime!
    var myTimer: NSTimer!
    var titleString : String!
    var isPresentedView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("videoPreviewView viewDidLoad begin")
        self.screenName = VideoPreviewViewScreenName
        // Do any additional setup after loading the view.
        if titleString != nil
        {
            titleLabel.text = titleString
        }
        if itemUrl != nil
        {
            dispatch_async(dispatch_get_main_queue(), { 
//                let asset = AVAsset(URL: self.itemUrl)
//                let playerItem = AVPlayerItem(asset: asset)
//                self.avPlayer = AVPlayer(playerItem: playerItem)
//                NSNotificationCenter.defaultCenter().addObserver(self,
//                    selector: #selector(VideoPreviewView.restartVideoFromBeginning),
//                    name: AVPlayerItemDidPlayToEndTimeNotification,
//                    object: self.avPlayer.currentItem)
//                self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
//                self.view.layer.addSublayer(self.avPlayerLayer)
//                self.avPlayerLayer.frame = self.view.bounds
//                self.avPlayer.pause()
                
                let asset = AVAsset(URL: self.itemUrl)
                let playerItem = AVPlayerItem(asset: asset)
                self.avPlayer = AVPlayer(playerItem: playerItem)
                self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
                NSNotificationCenter.defaultCenter().addObserver(self,
                                        selector: #selector(VideoPreviewView.restartVideoFromBeginning),
                                        name: AVPlayerItemDidPlayToEndTimeNotification,
                                        object: self.avPlayer.currentItem)
                self.avPlayerLayer.frame = self.view.bounds
                self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.view.layer.addSublayer(self.avPlayerLayer)
                self.avPlayerLayer.hidden = false
                self.avPlayer.seekToTime(kCMTimeZero)
                print("videoPreviewView viewDidLoad end")
            })
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.avPlayer.currentItem)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    /**
     Automatically Restarts the howtotakevideo after end of video playing.
     */
    func restartVideoFromBeginning() {
        print("videoPreviewView restartVideoFromBeginning begin")
        let seconds: Int64 = 0
        let preferredTimeScale: Int32 = 1
        let seekTime: CMTime = CMTimeMake(seconds, preferredTimeScale)
        avPlayer?.seekToTime(seekTime)
        avPlayer?.pause()
        pauseButton.hidden=true
        playButton.hidden = false
        closeViewButton.hidden=false
        print("videoPreviewView restartVideoFromBeginning end")
    }

    /**
     Playing the howtotakevideo when it was paused.
     
     - parameter sender: paly button from interface.
     */
    
    @IBAction func playVideo(sender: AnyObject) {
//        duration = avPlayer.currentItem!.asset.duration
//        totalDuration = Float(CMTimeGetSeconds(duration))
//        print(totalDuration)
        print("videoPreviewView playVideo begin")
        avPlayer.play()
        slider.hidden=false
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(VideoPreviewView.updateSlider), userInfo: nil, repeats: true)
        slider.addTarget(self, action: #selector(VideoPreviewView.sliderValueDidChange(_: )), forControlEvents: UIControlEvents.ValueChanged)
        slider.minimumValue = 0.0
        slider.continuous = true
        pauseButton.hidden=false
        playButton.hidden=true
        closeViewButton.hidden = false
        print("videoPreviewView playVideo end")
    }
    
    /**
     Update the slider respect with the video duration.
     */
    
    func updateSlider() {
        print("videoPreviewView updateSlider begin")
        currentTime = Float(CMTimeGetSeconds(avPlayer.currentTime()))
        duration = avPlayer.currentItem!.asset.duration
        totalDuration = Float(CMTimeGetSeconds(duration))
        slider.value = currentTime // Setting slider value as current time
        slider.maximumValue = totalDuration // Setting maximum value as total duration of the video
        print("videoPreviewView updateSlider end")
    }
    
    /**
     Update the video current time respect with the slider value.
     
     - parameter sender: slider from interface.
     */
    
    func sliderValueDidChange(sender: UISlider!) {
        print("videoPreviewView sliderValueDidChange begin")
        timeInSecond=slider.value
        newtime = CMTimeMakeWithSeconds(Double(timeInSecond), 1)// Setting new time using slider value
        avPlayer.seekToTime(newtime)
        print("videoPreviewView sliderValueDidChange end")
    }
    
    /**
     Pause video playing.
     
     - parameter sender: pause button from interface.
     */
    @IBAction func pausesButtonAction(sender: AnyObject) {
        print("videoPreviewView pausesButtonAction begin")
        pauseButton.hidden=true
        playButton.hidden = false
        avPlayer.pause()
        print("videoPreviewView pausesButtonAction end")
    }
    
    /**
     Dismiss the current view
     
     - parameter sender: close button from interface.
     */
    @IBAction func closeViewAction(sender: AnyObject) {
        print("videoPreviewView closeViewAction begin")
        pauseButton.hidden=true
        self.avPlayer.pause()
        if isPresentedView
        {
            self.avPlayerLayer.removeFromSuperlayer()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else
        {
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
        print("videoPreviewView closeViewAction end")
    }
}

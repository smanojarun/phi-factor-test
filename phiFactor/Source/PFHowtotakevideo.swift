//
//  PFHowtotakevideo.swift
//  PhiFactor
//
//  Created by Apple on 20/05/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import UIKit
import AVFoundation

class PFHowtotakevideo: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var pfhbackroundimage: UIImageView!
    @IBOutlet weak var layerviewRemove: UIButton!
    @IBOutlet weak var layerviewResume: UIButton!
    @IBOutlet var pfhBaseview: UIView!
    var avPlayer1 = AVPlayer()
    var avPlayerLayer1: AVPlayerLayer!
    var currentTime: Float!
    var totalDuration: Float!
    var duration: CMTime!
    var timeInSecond: Float!
    var newtime: CMTime!
     var myTimer: NSTimer!
    var cameraModel: PFCameraScreenModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        cameraModel = PFCameraScreenModel()
        avPlayerLayer1 = AVPlayerLayer(player: avPlayer1)
        self.pfhBaseview.layer.insertSublayer(avPlayerLayer1, atIndex: 0)
        let path2 = NSBundle.mainBundle().pathForResource("splashanimation", ofType: "mp4")
        let url = NSURL.fileURLWithPath(path2!)
        let playerItem = AVPlayerItem(URL: url)
        avPlayer1.replaceCurrentItemWithPlayerItem(playerItem)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PFHowtotakevideo.restartdemoVideoFromBeginning),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: avPlayer1.currentItem)
        avPlayerLayer1.frame = self.pfhBaseview.bounds
        // Dispose of any resources that can be recreated.
    }

    func restartdemoVideoFromBeginning() {
        pfhbackroundimage.hidden=false
    }

    /**
     update the slider value using currentTime and duration of the avplayer
     */
    
    func updateSlider() {
        currentTime = Float(CMTimeGetSeconds(avPlayer1.currentTime()))
        duration = avPlayer1.currentItem!.asset.duration
        totalDuration = Float(CMTimeGetSeconds(duration))
        slider.value = currentTime
        slider.maximumValue = totalDuration
    }

    // Seeking video while changing the slider value

    func sliderValueDidChange(sender: UISlider!) {
        timeInSecond=slider.value
        newtime = CMTimeMakeWithSeconds(Double(timeInSecond), 1)
        avPlayer1.seekToTime(newtime)
     }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
         // Start the playback
        avPlayer1.play()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func removeview(sender: AnyObject) {
        avPlayer1.pause()
        slider.hidden=true
        pfhbackroundimage.hidden=false

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("PFSinginViewController") as! PFSinginViewController
        self.presentViewController(nextViewController, animated: true, completion: nil)
    }

    @IBAction func resumeAction(sender: AnyObject) {
        pfhbackroundimage.hidden=true
        slider.hidden=false
        avPlayerLayer1 = AVPlayerLayer(player: avPlayer1)
        self.pfhBaseview.layer.insertSublayer(avPlayerLayer1, atIndex: 0)
        let path2 = NSBundle.mainBundle().pathForResource("splashanimation", ofType: "mp4")
        let url = NSURL.fileURLWithPath(path2!)
        let playerItem = AVPlayerItem(URL: url)
        avPlayer1.replaceCurrentItemWithPlayerItem(playerItem)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PFHowtotakevideo.restartdemoVideoFromBeginning),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: avPlayer1.currentItem)
        avPlayerLayer1.frame = self.pfhBaseview.bounds
        avPlayer1.play()
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(PFHowtotakevideo.updateSlider), userInfo: nil, repeats: true)
        slider.addTarget(self, action: #selector(PFHowtotakevideo.sliderValueDidChange(_: )), forControlEvents: UIControlEvents.ValueChanged)
        slider.minimumValue = 0.0
        slider.continuous = true
    }

}

//
//  PFIdle.swift
//  PhiFactor
//
//  Created by Apple on 30/08/16.
//  Copyright © 2016 Hubino. All rights reserved.
//

import UIKit
import Foundation

private let g_secs = 300.0
typealias dispatch_cancelable_closure = (cancel : Bool) -> Void

class PFIdle: UIApplication, ABPadLockScreenViewControllerDelegate
{
    var idle_timer : dispatch_cancelable_closure?
    
    override init()
    {
        super.init()
        reset_idle_timer()
    }
    
    override func sendEvent( event: UIEvent )
    {
        super.sendEvent( event )
        
        if let all_touches = event.allTouches() {
            if ( all_touches.count > 0 ) {
                let phase = (all_touches.first! as UITouch).phase
                if phase == UITouchPhase.Began {
                    reset_idle_timer()
                }
            }
        }
    }
    
    private func reset_idle_timer()
    {
        cancel_delay( idle_timer )
        idle_timer = delay( g_secs ) { self.idle_timer_exceeded() }
    }
    
    func idle_timer_exceeded()
    {
        print( "Ring ----------------------- Do some Idle Work!" )
        let currentViewController = UIApplication.topViewController()
        if currentViewController?.isKindOfClass(PhiFactorIntro) == false{
            PFGlobalConstants.authenticateUserByTouchID({ (status) in
                switch status{
                case .authorized:
                    break
                case .unAuthorized:
                    dispatch_async(dispatch_get_main_queue(), {
                        if (PFGlobalConstants.isPasscodeAvailable()) {
                            let lockScreen = ABPadLockScreenViewController(delegate: self, complexPin: false)
                            lockScreen.setAllowedAttempts(3)
                            lockScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                            lockScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                            isAuthorizationRequesting = true;
                            UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(lockScreen, animated: true, completion: nil)
                        }
                        else
                        {
                            UIAlertView(title: "", message: "No registered passcode found.", delegate: nil, cancelButtonTitle: "Ok").show()
                        }
                    })
                    break
                case .unKnown:
                    dispatch_async(dispatch_get_main_queue(), {
                        UIAlertView(title: "", message: "Check touch id configured and enabled on your device to begin.", delegate: nil, cancelButtonTitle: "Ok").show()
                    })
                    break
                case .canceled:
                    PFGlobalConstants.logoutUser()
                    break
                }
            })
        }
        

        reset_idle_timer()
    }
    //MARK: Lock Screen Delegate
    func padLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!, validatePin pin: String!) -> Bool {
        print("Validating Pin \(pin)")
        let thePin = NSUserDefaults.standardUserDefaults().stringForKey("PF_Passcode")
        return thePin == pin
    }
    
    func unlockWasSuccessfulForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Successful!")
        isAuthorizationRequesting = false;
        UIApplication.sharedApplication().keyWindow?.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func unlockWasUnsuccessful(falsePin: String!, afterAttemptNumber attemptNumber: Int, padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Failed Attempt \(attemptNumber) with incorrect pin \(falsePin)")
        if attemptNumber == 3
        {
            isAuthorizationRequesting = false;
            UIApplication.sharedApplication().keyWindow?.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func unlockWasCancelledForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Cancled")
        PFGlobalConstants.logoutUser()
        isAuthorizationRequesting = false;
        UIApplication.sharedApplication().keyWindow?.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
}


func delay(time:NSTimeInterval, closure:()->Void) ->  dispatch_cancelable_closure? {
    
    func dispatch_later(clsr:()->Void) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(time * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), clsr)
    }
    
    var closure:dispatch_block_t? = closure
    var cancelableClosure:dispatch_cancelable_closure?
    
    let delayedClosure:dispatch_cancelable_closure = { cancel in
        if closure != nil {
            if (cancel == false) {
                dispatch_async(dispatch_get_main_queue(), closure!);
            }
        }
        closure = nil
        cancelableClosure = nil
    }
    
    cancelableClosure = delayedClosure
    
    dispatch_later {
        if let delayedClosure = cancelableClosure {
            delayedClosure(cancel: false)
        }
    }
    
    return cancelableClosure;
}

func cancel_delay(closure:dispatch_cancelable_closure?) {
    
    if closure != nil {
        closure!(cancel: true)
    }
}
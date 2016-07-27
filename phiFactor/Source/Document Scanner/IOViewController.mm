//
//  IOViewController.m
//  instaoverlay
//
//  Created by MacPro_IOS_v2 on 09/06/16.
//  Copyright © 2016 mackh ag. All rights reserved.
//

#import "IOViewController.h"
#import "IPDFCameraViewController.h"
#import "MAImagePickerControllerAdjustViewController.h"
#import "UIImage+fixOrientation.h"

@interface IOViewController () <autoCaptureDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet IPDFCameraViewController *cameraViewController;
@property (weak, nonatomic) IBOutlet UIImageView *focusIndicator;
@property (assign, nonatomic) BOOL isImageCaptured;

- (IBAction)focusGesture:(id)sender;

- (IBAction)captureButton:(id)sender;

@end

@implementation IOViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.cameraViewController setupCameraView];
    [self.cameraViewController setCameraViewType:IPDFCameraViewTypeNormal];
    [self.cameraViewController setEnableBorderDetection:YES];
    [self updateTitleLabel];
    self.cameraViewController.delegate = self;
}
- (void)viewWillAppear:(BOOL)animated
{
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    _isImageCaptured = true;
    [self.cameraViewController stop];
}
- (void)viewDidAppear:(BOOL)animated
{
    _isImageCaptured = false;
    [self.cameraViewController start];
    [self.cameraViewController resetCameraViewController];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark CameraVC Actions

- (IBAction)focusGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [sender locationInView:self.cameraViewController];
        
        [self focusIndicatorAnimateToPoint:location];
        
        [self.cameraViewController focusAtPoint:location completionHandler:^
         {
             [self focusIndicatorAnimateToPoint:location];
         }];
    }
}

- (void)focusIndicatorAnimateToPoint:(CGPoint)targetPoint
{
    [self.focusIndicator setCenter:targetPoint];
    self.focusIndicator.alpha = 0.0;
    self.focusIndicator.hidden = NO;
    
    [UIView animateWithDuration:0.4 animations:^
     {
         self.focusIndicator.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.4 animations:^
          {
              self.focusIndicator.alpha = 0.0;
          }];
     }];
}

- (IBAction)borderDetectToggle:(id)sender
{
    BOOL enable = !self.cameraViewController.isBorderDetectionEnabled;
    [self changeButton:sender targetTitle:(enable) ? @"CROP On" : @"CROP Off" toStateEnabled:enable];
    self.cameraViewController.enableBorderDetection = enable;
    [self updateTitleLabel];
}

- (IBAction)filterToggle:(id)sender
{
    [self.cameraViewController setCameraViewType:(self.cameraViewController.cameraViewType == IPDFCameraViewTypeBlackAndWhite) ? IPDFCameraViewTypeNormal : IPDFCameraViewTypeBlackAndWhite];
    [self updateTitleLabel];
}

- (IBAction)torchToggle:(id)sender
{
    BOOL enable = !self.cameraViewController.isTorchEnabled;
    [self changeButton:sender targetTitle:(enable) ? @"FLASH On" : @"FLASH Off" toStateEnabled:enable];
    self.cameraViewController.enableTorch = enable;
}

- (void)updateTitleLabel
{
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    animation.duration = 0.35;
    [self.titleLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    NSString *filterMode = (self.cameraViewController.cameraViewType == IPDFCameraViewTypeBlackAndWhite) ? @"TEXT FILTER" : @"COLOR FILTER";
    self.titleLabel.text = [filterMode stringByAppendingFormat:@" | %@",(self.cameraViewController.isBorderDetectionEnabled)?@"AUTOCROP On":@"AUTOCROP Off"];
}

- (void)changeButton:(UIButton *)button targetTitle:(NSString *)title toStateEnabled:(BOOL)enabled
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:(enabled) ? [UIColor colorWithRed:1 green:0.81 blue:0 alpha:1] : [UIColor whiteColor] forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark CameraVC Capture Image

- (IBAction)captureButton:(id)sender
{
    if (_isImageCaptured == false)
    {
        _isImageCaptured = true;
        [self.cameraViewController setCaptureStatus:true];
        [self.cameraViewController captureImageWithCompletionHander:^(NSString *imageFilePath)
         {
             /*
              
              __weak typeof(self) weakSelf = self;
              
              UIImageView *captureImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imageFilePath]];
              captureImageView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
              captureImageView.frame = CGRectOffset(weakSelf.view.bounds, 0, -weakSelf.view.bounds.size.height);
              captureImageView.alpha = 1.0;
              captureImageView.contentMode = UIViewContentModeScaleAspectFit;
              captureImageView.userInteractionEnabled = YES;
              [weakSelf.view addSubview:captureImageView];
              
              UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(dismissPreview:)];
              [captureImageView addGestureRecognizer:dismissTap];
              
              [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.7 options:UIViewAnimationOptionAllowUserInteraction animations:^
              {
              captureImageView.frame = weakSelf.view.bounds;
              } completion:nil];*/
             
//             [self capturedImageFilePath:imageFilePath];
             
             MAImagePickerControllerAdjustViewController *adjustViewController = [[MAImagePickerControllerAdjustViewController alloc] init];
             adjustViewController.sourceImage = [[UIImage imageWithContentsOfFile:imageFilePath] fixOrientation];
             [self.navigationController pushViewController:adjustViewController animated:NO];

         }];

    }
}

- (void)dismissPreview:(UITapGestureRecognizer *)dismissTap
{
    [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionAllowUserInteraction animations:^
     {
         dismissTap.view.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height);
     }
                     completion:^(BOOL finished)
     {
         [dismissTap.view removeFromSuperview];
         [self.cameraViewController resetCameraViewController];
     }];
}

-(void)capturedImageFilePath:(NSString *) filePath
{
   // __weak typeof(self) weakSelf = self;
    
    /*UIImageView *captureImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:filePath]];
    captureImageView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    captureImageView.frame = CGRectOffset(weakSelf.view.bounds, 0, -weakSelf.view.bounds.size.height);
    captureImageView.alpha = 1.0;
    captureImageView.contentMode = UIViewContentModeScaleAspectFit;
    captureImageView.userInteractionEnabled = YES;
    [weakSelf.view addSubview:captureImageView];
    
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(dismissPreview:)];
    [captureImageView addGestureRecognizer:dismissTap];
    
    [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.7 options:UIViewAnimationOptionAllowUserInteraction animations:^
     {
         captureImageView.frame = weakSelf.view.bounds;
     } completion:nil];
    */
    if (_isImageCaptured == false)
    {
        _isImageCaptured = true;
        MAImagePickerControllerAdjustViewController *adjustViewController = [[MAImagePickerControllerAdjustViewController alloc] init];
        adjustViewController.sourceImage = [[UIImage imageWithContentsOfFile:filePath] fixOrientation];
        
//        CATransition* transition = [CATransition animation];
//        transition.duration = 0.4;
//        transition.type = kCATransitionFade;
//        transition.subtype = kCATransitionFromBottom;
//        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController pushViewController:adjustViewController animated:NO];
    }
    
}
- (IBAction)cancelAction:(id)sender {
    self.cameraViewController.isCapturingStill = true;
    [self.navigationController popToRootViewControllerAnimated:true];
//    AppDelegate* sharedDelegate = [AppDelegate appDelegate];
//    MainViewController *mainView = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
//    [sharedDelegate setRootViewForWindow:mainView];
}
- (IBAction)skipToCameraViewAction:(id)sender {
    self.cameraViewController.isCapturingStill = true;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *cameraView = [storyBoard instantiateViewControllerWithIdentifier:@"PFCameraviewcontrollerscreen"];
    [self.navigationController pushViewController:cameraView animated:true];
}
@end

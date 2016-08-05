//
//  IPDFCameraViewController.m
//  InstaPDF
//
//  Created by Maximilian Mackh on 06/01/15.
//  Copyright (c) 2015 mackh ag. All rights reserved.
//

#import "IPDFCameraViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>

#import <MobileCoreServices/MobileCoreServices.h>

#import <GLKit/GLKit.h>

@interface IPDFCameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) AVCaptureDevice *captureDevice;
@property (nonatomic,strong) EAGLContext *context;

@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;

@property (nonatomic, assign) BOOL forceStop;
@property (nonatomic, assign) CGSize intrinsicContentSize;

@property (nonatomic, strong) NSTimer * captureTimer;
@property (nonatomic, strong) NSMutableArray * borderRectangleFrameArray;

@end

@implementation IPDFCameraViewController
{
    CIContext *_coreImageContext;
    GLuint _renderBuffer;
    GLKView *_glkView;
    
    BOOL _isStopped;
    
    CGFloat _imageDedectionConfidence;
    NSTimer *_borderDetectTimeKeeper;
    BOOL _borderDetectFrame;
    CIRectangleFeature *_borderDetectLastRectangleFeature;
    
    BOOL _isCapturing;
    dispatch_queue_t _captureQueue;
    BOOL isCaptureStateSteady;
    int timerCount;
    
    
}
@synthesize delegate;
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_backgroundMode) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_foregroundMode) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    _captureQueue = dispatch_queue_create("com.instapdf.AVCameraCaptureQueue", DISPATCH_QUEUE_SERIAL);
}

- (void)_backgroundMode
{
    self.forceStop = YES;
}

- (void)_foregroundMode
{
    self.forceStop = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createGLKView
{
    NSLog(@"IPDFCameraViewController createGLKView begin");
    if (self.context) return;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = [[GLKView alloc] initWithFrame:self.bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.translatesAutoresizingMaskIntoConstraints = YES;
    view.context = self.context;
    view.contentScaleFactor = 1.0f;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self insertSubview:view atIndex:0];
    _glkView = view;
    _coreImageContext = [CIContext contextWithEAGLContext:self.context options:@{ kCIContextWorkingColorSpace : [NSNull null],kCIContextUseSoftwareRenderer : @(NO)}];
    NSLog(@"IPDFCameraViewController createGLKView end");
}

- (void)setupCameraView
{
    [self createGLKView];
    
    
    
    
    NSArray *possibleDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    
    
    
    AVCaptureDevice *device = [possibleDevices firstObject];
    if (!device) return;
    
    _imageDedectionConfidence = 0.0;
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.captureSession = session;
    [session beginConfiguration];
    self.captureDevice = device;
    
    NSError *error = nil;
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    [session addInput:input];
    
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
//    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
//    [dataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}];
    [dataOutput setSampleBufferDelegate:self queue:_captureQueue];
    [session addOutput:dataOutput];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [session addOutput:self.stillImageOutput];
    
    AVCaptureConnection *connection = [dataOutput.connections firstObject];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    if (device.isFlashAvailable)
    {
        [device lockForConfiguration:nil];
        [device setFlashMode:AVCaptureFlashModeOff];
        [device unlockForConfiguration];
        
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        {
            [device lockForConfiguration:nil];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        }
    }
    
    [session commitConfiguration];
    [self resetCameraViewController];
}

- (void)setCameraViewType:(IPDFCameraViewType)cameraViewType
{
    UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *viewWithBlurredBackground =[[UIVisualEffectView alloc] initWithEffect:effect];
    viewWithBlurredBackground.frame = self.bounds;
    [self insertSubview:viewWithBlurredBackground aboveSubview:_glkView];
    
    _cameraViewType = cameraViewType;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [viewWithBlurredBackground removeFromSuperview];
    });
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.forceStop) return;
    NSLog(@"IPDFCameraViewController didOutputSampleBuffer begin");
    if (_isStopped || _isCapturing || !CMSampleBufferIsValid(sampleBuffer) || _isCapturingStill) return;
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    if (self.cameraViewType != IPDFCameraViewTypeNormal)
    {
        image = [self filteredImageUsingEnhanceFilterOnImage:image];
    }
    else
    {
        image = [self filteredImageUsingContrastFilterOnImage:image];
    }
    
    if (self.isBorderDetectionEnabled)
    {
        if (_borderDetectFrame)
        {
            _borderDetectLastRectangleFeature = [self biggestRectangleInRectangles:[[self highAccuracyRectangleDetector] featuresInImage:image]];
            _borderDetectFrame = NO;
        }
        
        if (_borderDetectLastRectangleFeature)
        {
            _imageDedectionConfidence += .5;
            
            image = [self drawHighlightOverlayForPoints:image topLeft:_borderDetectLastRectangleFeature.topLeft topRight:_borderDetectLastRectangleFeature.topRight bottomLeft:_borderDetectLastRectangleFeature.bottomLeft bottomRight:_borderDetectLastRectangleFeature.bottomRight];
            [_borderRectangleFrameArray addObject:_borderDetectLastRectangleFeature];
        }
        else
        {
            _imageDedectionConfidence = 0.0f;
        }
    }
    
    if (self.context && _coreImageContext)
    {
        if(_context != [EAGLContext currentContext])
        {
            [EAGLContext setCurrentContext:_context];
        }
        [_glkView bindDrawable];
        
        //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCIImage:image]];
       // imageView.image = [self drawLineonTop:[UIColor greenColor] image:imageView.image];
        
        [_coreImageContext drawImage:image inRect:self.bounds fromRect:[image extent]];
        if([_glkView enableSetNeedsDisplay])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            [_glkView setNeedsDisplay];
                [_glkView display];
            });
        }
        
        if(_intrinsicContentSize.width != image.extent.size.width) {
            self.intrinsicContentSize = image.extent.size;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self invalidateIntrinsicContentSize];
            });
        }
        
        image = nil;
    }
    NSLog(@"IPDFCameraViewController didOutputSampleBuffer end");
}

- (CGSize)intrinsicContentSize
{
    if(_intrinsicContentSize.width == 0 || _intrinsicContentSize.height == 0) {
        return CGSizeMake(1, 1); //just enough so rendering doesn't crash
    }
    return _intrinsicContentSize;
}

- (void)enableBorderDetectFrame
{
    _borderDetectFrame = YES;
}

- (CIImage *)drawHighlightOverlayForPoints:(CIImage *)image topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight
{
    CIImage *overlay = [[CIImage alloc] initWithColor:[CIColor colorWithRed:242/255.0 green:78/255.0 blue:21/255.0 alpha:0.4]];
   // CIImage *overlay = [[CIImage alloc] initWithImage:[UIImage imageNamed:@"focusIndicator.png"]];
    overlay = [overlay imageByCroppingToRect:image.extent];
    overlay = [overlay imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:@{@"inputExtent":[CIVector vectorWithCGRect:image.extent],@"inputTopLeft":[CIVector vectorWithCGPoint:topLeft],@"inputTopRight":[CIVector vectorWithCGPoint:topRight],@"inputBottomLeft":[CIVector vectorWithCGPoint:bottomLeft],@"inputBottomRight":[CIVector vectorWithCGPoint:bottomRight]}];
    
    return [overlay imageByCompositingOverImage:image];
}

-(CIImage * )drawBorderForImage:(CIImage *)sourceImage topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight
{
    CIImage *overlay1 = [CIImage imageWithColor:[CIColor colorWithRed:1 green:1 blue:1 alpha:0.6]];
    overlay1 = [overlay1 imageByCroppingToRect:sourceImage.extent];
    overlay1 = [overlay1 imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:@{@"inputExtent":[CIVector vectorWithCGRect:sourceImage.extent],@"inputTopLeft":[CIVector vectorWithCGPoint:CGPointMake(topLeft.x - 5, topLeft.y + 5)],@"inputTopRight":[CIVector vectorWithCGPoint:CGPointMake(topRight.x + 5, topRight.y + 5)],@"inputBottomLeft":[CIVector vectorWithCGPoint:CGPointMake(topLeft.x - 5, topLeft.y )],@"inputBottomRight":[CIVector vectorWithCGPoint:CGPointMake(topRight.x + 5, topRight.y ) ]}];
    CIImage * overlay = [ overlay1 imageByCompositingOverImage:overlay1];
    return overlay;
}
- (void)start
{
    _isStopped = NO;
    
    [self.captureSession startRunning];
    
    _borderDetectTimeKeeper = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(enableBorderDetectFrame) userInfo:nil repeats:YES];
    
    [self hideGLKView:NO completion:nil];
}

- (void)stop
{
    _isStopped = YES;
    
    [self.captureSession stopRunning];
    
    [_borderDetectTimeKeeper invalidate];
    
    [self hideGLKView:YES completion:nil];
}

- (void)setEnableTorch:(BOOL)enableTorch
{
    _enableTorch = enableTorch;
    
    AVCaptureDevice *device = self.captureDevice;
    if ([device hasTorch] && [device hasFlash])
    {
        [device lockForConfiguration:nil];
        if (enableTorch)
        {
            [device setTorchMode:AVCaptureTorchModeOn];
        }
        else
        {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}

- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)())completionHandler
{
    AVCaptureDevice *device = self.captureDevice;
    CGPoint pointOfInterest = CGPointZero;
    CGSize frameSize = self.bounds.size;
    pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        NSError *error;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
            {
                [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                [device setFocusPointOfInterest:pointOfInterest];
            }
            
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                [device setExposurePointOfInterest:pointOfInterest];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                completionHandler();
            }
            
            [device unlockForConfiguration];
        }
    }
    else
    {
        completionHandler();
    }
}

- (void)captureImageWithCompletionHander:(void(^)(NSString *imageFilePath))completionHandler
{
    dispatch_suspend(_captureQueue);
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) break;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         if (error)
         {
             dispatch_resume(_captureQueue);
             return;
         }
         
         __block NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"ipdf_img_%i.jpeg",(int)[NSDate date].timeIntervalSince1970]];
         
         @autoreleasepool
         {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             CIImage *enhancedImage = [[CIImage alloc] initWithData:imageData options:@{kCIImageColorSpace:[NSNull null]}];
             
             
             
             
//             NSData *imageDatas = imageData;
//             
//             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//             NSString *documentsDirectory = [paths objectAtIndex:0];
//             
//             NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg",@"cached"]];
//             
//             NSLog((@"pre writing to file"));
//             if (![imageDatas writeToFile:imagePath atomically:NO])
//             {
//                 NSLog((@"Failed to cache image data to disk"));
//             }
//             else
//             {
//                 NSLog(@"the cachedImagedPath is %@",imagePath);
//             }
             
             
//             NSData *imgData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];;
//             
//             
//             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//             NSString *documentsDirectory = [paths objectAtIndex:0];
//             
//             NSString *localFilePath= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"frame_%d.jpeg",1]];
//             NSLog(@"local file path at save --------------- %@",localFilePath);
//             [imgData writeToFile:localFilePath atomically:YES];
             
             
             
             
             
             imageData = nil;
             
             if (weakSelf.cameraViewType == IPDFCameraViewTypeBlackAndWhite)
             {
                 enhancedImage = [self filteredImageUsingEnhanceFilterOnImage:enhancedImage];
             }
             else
             {
                 enhancedImage = [self filteredImageUsingContrastFilterOnImage:enhancedImage];
             }
             
             if (weakSelf.isBorderDetectionEnabled && rectangleDetectionConfidenceHighEnough(_imageDedectionConfidence))
             {
                 CIRectangleFeature *rectangleFeature = [self biggestRectangleInRectangles:[[self highAccuracyRectangleDetector] featuresInImage:enhancedImage]];
                 
                 if (rectangleFeature)
                 {
                     enhancedImage = [self correctPerspectiveForImage:enhancedImage withFeatures:rectangleFeature];
                 }
             }
             
//             CIFilter *transform = [CIFilter filterWithName:@"CIAffineTransform"];
//             [transform setValue:enhancedImage forKey:kCIInputImageKey];
//             NSValue *rotation = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(-90 * (M_PI/180))];
//             [transform setValue:rotation forKey:@"inputTransform"];
//             enhancedImage = [transform outputImage];
             
             if (!enhancedImage || CGRectIsEmpty(enhancedImage.extent)) return;
             
             static CIContext *ctx = nil;
             if (!ctx)
             {
                 ctx = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace:[NSNull null]}];
             }
             
             CGSize bounds = enhancedImage.extent.size;
             bounds = CGSizeMake(floorf(bounds.width / 4) * 4,floorf(bounds.height / 4) * 4);
             CGRect extent = CGRectMake(enhancedImage.extent.origin.x, enhancedImage.extent.origin.y, bounds.width, bounds.height);
             
             static int bytesPerPixel = 8;
             uint rowBytes = bytesPerPixel * bounds.width;
             uint totalBytes = rowBytes * bounds.height;
             uint8_t *byteBuffer = malloc(totalBytes);
             
             CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
             
             [ctx render:enhancedImage toBitmap:byteBuffer rowBytes:rowBytes bounds:extent format:kCIFormatRGBA8 colorSpace:colorSpace];
             
             CGContextRef bitmapContext = CGBitmapContextCreate(byteBuffer,bounds.width,bounds.height,bytesPerPixel,rowBytes,colorSpace,kCGImageAlphaNoneSkipLast);
             
             
             CGImageRef imgRef = CGBitmapContextCreateImage(bitmapContext);
             CGColorSpaceRelease(colorSpace);
             CGContextRelease(bitmapContext);
             free(byteBuffer);
             
             if (imgRef == NULL)
             {
                 CFRelease(imgRef);
                 return;
             }
             saveCGImageAsJPEGToFilePath(imgRef, filePath);
             CFRelease(imgRef);
             
             dispatch_async(dispatch_get_main_queue(), ^
             {
                completionHandler(filePath);
                dispatch_resume(_captureQueue);
             });
             
             _imageDedectionConfidence = 0.0f;
         }
     }];
}

void saveCGImageAsJPEGToFilePath(CGImageRef imageRef, NSString *filePath)
{
    @autoreleasepool
    {
        CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:filePath];
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);
        CGImageDestinationAddImage(destination, imageRef, nil);
        CGImageDestinationFinalize(destination);
        CFRelease(destination);
    }
}

- (void)hideGLKView:(BOOL)hidden completion:(void(^)())completion
{
    [UIView animateWithDuration:0.1 animations:^
    {
        _glkView.alpha = (hidden) ? 0.0 : 1.0;
    }
    completion:^(BOOL finished)
    {
        if (!completion) return;
        completion();
    }];
}

- (CIImage *)filteredImageUsingEnhanceFilterOnImage:(CIImage *)image
{
    return [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, image, @"inputBrightness", [NSNumber numberWithFloat:0.0], @"inputContrast", [NSNumber numberWithFloat:1.14], @"inputSaturation", [NSNumber numberWithFloat:0.0], nil].outputImage;
}

- (CIImage *)filteredImageUsingContrastFilterOnImage:(CIImage *)image
{
    return [CIFilter filterWithName:@"CIColorControls" withInputParameters:@{@"inputContrast":@(1.1),kCIInputImageKey:image}].outputImage;
}

- (CIImage *)correctPerspectiveForImage:(CIImage *)image withFeatures:(CIRectangleFeature *)rectangleFeature
{
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:rectangleFeature.topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomRight];
    return [image imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
}

- (CIDetector *)rectangleDetetor
{
    static CIDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
          detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyLow,CIDetectorTracking : @(YES)}];
    });
    return detector;
}

- (CIDetector *)highAccuracyRectangleDetector
{
    static CIDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    });
    return detector;
}

- (CIRectangleFeature *)biggestRectangleInRectangles:(NSArray *)rectangles
{
    if (![rectangles count]) return nil;
    
    float halfPerimiterValue = 0;
    
    CIRectangleFeature *biggestRectangle = [rectangles firstObject];
    
    for (CIRectangleFeature *rect in rectangles)
    {
        CGPoint p1 = rect.topLeft;
        CGPoint p2 = rect.topRight;
        CGFloat width = hypotf(p1.x - p2.x, p1.y - p2.y);
        
        CGPoint p3 = rect.topLeft;
        CGPoint p4 = rect.bottomLeft;
        CGFloat height = hypotf(p3.x - p4.x, p3.y - p4.y);
        
        CGFloat currentHalfPerimiterValue = height + width;
        
        if (halfPerimiterValue < currentHalfPerimiterValue)
        {
            halfPerimiterValue = currentHalfPerimiterValue;
            biggestRectangle = rect;
        }
    }
    
    return biggestRectangle;
}

BOOL rectangleDetectionConfidenceHighEnough(float confidence)
{
    return (confidence > 1.0);
}

-(void) rectangleCheck
{
    if (_borderRectangleFrameArray != nil && _borderRectangleFrameArray.count != 0)
    {
        timerCount++;
        NSArray * tempArray = _borderRectangleFrameArray;
        NSMutableArray *framesMatchArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < tempArray.count-1; i++) {
            CIRectangleFeature * previousResult = [tempArray objectAtIndex:i];
            CIRectangleFeature * nextResult = [tempArray objectAtIndex:i+1];
            
            if ([self percentCheck:previousResult.bounds.origin.x y:previousResult.bounds.origin.y current:nextResult.bounds.origin.x y:nextResult.bounds.origin.y] &&
                [self percentCheck:previousResult.bounds.size.width y:previousResult.bounds.size.height current:nextResult.bounds.size.width y:nextResult.bounds.size.height] && [self percentCheck:previousResult.topLeft.x y:previousResult.topLeft.y current:nextResult.topLeft.x y:nextResult.topLeft.y]
                && ([self percentCheck:previousResult.topRight.x y:previousResult.topRight.y current:nextResult.topRight.x y:nextResult.topRight.y])
                && ([self percentCheck:previousResult.bottomLeft.x y:previousResult.bottomLeft.y current:nextResult.bottomLeft.x y:nextResult.bottomLeft.y])
                && [self percentCheck:previousResult.bottomRight.x y:previousResult.bottomRight.y current:nextResult.bottomRight.x y:nextResult.bottomRight.y])
            {
                [framesMatchArray addObject:[NSNumber numberWithBool:true]];
            }
            else
            {
                [framesMatchArray addObject:[NSNumber numberWithBool:false]];
            }
        }
        BOOL tempBool = true;
        for (NSNumber *value in framesMatchArray) {
            if ([value boolValue] == true && tempBool == true)
            {
                tempBool = true;
            }
            else
            {
                tempBool = false;
            }
        }
        if (tempBool == true) {
            isCaptureStateSteady = true;
        }
        else
        {
            isCaptureStateSteady = false;
            _borderRectangleFrameArray = [[NSMutableArray alloc] init];
            timerCount = 0;
        }
        if (timerCount > 10)
        {
            if ((isCaptureStateSteady == true) && (_isCapturingStill == false))
            {
//                CIRectangleFeature * previousResult = [tempArray objectAtIndex:tempArray.count-1];
//                CIRectangleFeature * nextResult = _borderDetectLastRectangleFeature;
//                
//                if ([self percentCheck:previousResult.bounds.origin.x y:previousResult.bounds.origin.y current:nextResult.bounds.origin.x y:nextResult.bounds.origin.y] &&
//                    [self percentCheck:previousResult.bounds.size.width y:previousResult.bounds.size.height current:nextResult.bounds.size.width y:nextResult.bounds.size.height] && [self percentCheck:previousResult.topLeft.x y:previousResult.topLeft.y current:nextResult.topLeft.x y:nextResult.topLeft.y]
//                    && ([self percentCheck:previousResult.topRight.x y:previousResult.topRight.y current:nextResult.topRight.x y:nextResult.topRight.y])
//                    && ([self percentCheck:previousResult.bottomLeft.x y:previousResult.bottomLeft.y current:nextResult.bottomLeft.x y:nextResult.bottomLeft.y])
//                    && [self percentCheck:previousResult.bottomRight.x y:previousResult.bottomRight.y current:nextResult.bottomRight.x y:nextResult.bottomRight.y])
//                {
//                    
//                }
                _isCapturingStill = true;
                isCaptureStateSteady = false;
                timerCount = 0;
                [_captureTimer invalidate ];
                [self captureImageWithCompletionHander:^(NSString *imageFilePath) {
                    
                    
                    [delegate capturedImageFilePath:imageFilePath];
                    
                    
                }];
            }
        }
        else
        {
            isCaptureStateSteady = false;
            _borderRectangleFrameArray = [[NSMutableArray alloc] init];

        }

    }
    else
    {
        isCaptureStateSteady = false;
        _borderRectangleFrameArray = [[NSMutableArray alloc] init];
    }
    
}

-(BOOL) percentCheck:(CGFloat)previousX y:(CGFloat)previousY current :(CGFloat)currentX y:(CGFloat)currentY
{
    CGFloat percentAddedPreviousX = previousX + (previousX * 0.02);
    CGFloat percentAddedPreviousY = previousY + (previousY * 0.02);
    CGFloat percentSubtractedPreviousX = previousX - (previousX * 0.02);
    CGFloat percentSubtractedPreviousY = previousY - (previousY * 0.02);
    
    if ((percentAddedPreviousX >= currentX || percentSubtractedPreviousX <= currentX) && (percentAddedPreviousY >= currentY || percentSubtractedPreviousY <= currentY))
    {
        return true;
    }
    else
    {
        return false;
    }
}
-(void)resetCameraViewController
{
    isCaptureStateSteady = false;
    timerCount = 0;
    _isCapturingStill = false;
    _borderRectangleFrameArray = [[NSMutableArray alloc] init];
    _captureTimer =  [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                      target: self
                                                    selector:@selector(rectangleCheck)
                                                    userInfo: nil repeats:YES];
}

-(void) setCaptureStatus:(BOOL)value
{
    _isCapturingStill = value;
}
- (UIImage *)addBorderToImage:(UIImage *)image {
    CGImageRef bgimage = [image CGImage];
    float width = CGImageGetWidth(bgimage);
    float height = CGImageGetHeight(bgimage);
    
    // Create a temporary texture data buffer
    void *data = malloc(width * height * 4);
    
    // Draw image to buffer
    CGContextRef ctx = CGBitmapContextCreate(data,
                                             width,
                                             height,
                                             8,
                                             width * 4,
                                             CGImageGetColorSpace(image.CGImage),
                                             kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(ctx, CGRectMake(0, 0, (CGFloat)width, (CGFloat)height), bgimage);
    
    //Set the stroke (pen) color
    CGContextSetStrokeColorWithColor(ctx, [UIColor greenColor].CGColor);
    
    //Set the width of the pen mark
    CGFloat borderWidth = (float)width*0.05;
    CGContextSetLineWidth(ctx, borderWidth);
    
    //Start at 0,0 and draw a square
    CGContextMoveToPoint(ctx, 0.0, 0.0);
    CGContextAddLineToPoint(ctx, 0.0, height);
    CGContextAddLineToPoint(ctx, width, height);
    CGContextAddLineToPoint(ctx, width, 0.0);
    CGContextAddLineToPoint(ctx, 0.0, 0.0);
    
    //Draw it
    CGContextStrokePath(ctx);
    
    // write it to a new image
    CGImageRef cgimage = CGBitmapContextCreateImage(ctx);
    UIImage *newImage = [UIImage imageWithCGImage:cgimage];
    //CFRelease(cgimage);
 //   CGContextRelease(ctx);
    
    // auto-released
    return newImage;
}

-(UIImage *)drawOutlie : (UIImage *) SOURCEIMAGe color : (UIColor *)colorValue
{
    CGFloat newImageKoef = 1.08;
    CGRect outlinedImageRect = CGRectMake(0.0, 0.0, SOURCEIMAGe.size.width * newImageKoef, SOURCEIMAGe.size.height * newImageKoef);
    CGRect imageRect = CGRectMake(SOURCEIMAGe.size.width * (newImageKoef - 1) * 0.5, SOURCEIMAGe.size.height * (newImageKoef - 1) * 0.5, SOURCEIMAGe.size.width, SOURCEIMAGe.size.height);
    UIGraphicsBeginImageContextWithOptions(outlinedImageRect.size, false, newImageKoef);
    [SOURCEIMAGe drawInRect:outlinedImageRect];
    struct CGContext * context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextSetFillColorWithColor(context, colorValue.CGColor);
    CGContextFillRect(context, outlinedImageRect);
    [SOURCEIMAGe drawInRect:imageRect];
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

-(UIImage *)makeRoundedImage:(UIImage *) image
                      radius: (float) radius;
{
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    imageLayer.contents = (id) image.CGImage;
    
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = radius;
    
    UIGraphicsBeginImageContext(image.size);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

-(UIImage *) drawLineonTop: (UIColor *)lineColor image:(UIImage *)originalImage
{
    // UIImage *originalImage = <the image you want to add a line to>
    // UIColor *lineColor = <the color of the line>
    
    UIGraphicsBeginImageContext(originalImage.size);
    
    // Pass 1: Draw the original image as the background
    [originalImage drawAtPoint:CGPointMake(0,0)];
    
    // Pass 2: Draw the line on top of original image
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, originalImage.size.width, 0);
    CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
    CGContextStrokePath(context);
    
    // Create new image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Tidy up
    UIGraphicsEndImageContext();
    return newImage;
}
@end



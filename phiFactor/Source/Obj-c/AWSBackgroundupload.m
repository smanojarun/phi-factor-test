/*
 * Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 * http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "AWSBackgroundupload.h"
//#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "PhiFactorPRD-Swift.h"

@interface AWSBackgroundupload ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation AWSBackgroundupload

NSDate *startTime ;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.progressView.progress = 0;
    self.statusLabel.text = @"Ready";

    __weak AWSBackgroundupload *weakSelf = self;
    self.completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                weakSelf.statusLabel.text = @"Failed to Upload";
            } else {
                //NSLog(@"Time: %f", -[startTime timeIntervalSinceNow]);
                weakSelf.statusLabel.text = @"Successfully Uploaded";
                weakSelf.progressView.progress = 1.0;
                
                Float64 time =  -[startTime timeIntervalSinceNow];
                weakSelf.resultView.editable=NO;
                weakSelf.resultView.text=[weakSelf timeResult:time];
                
            }
        });
    };

    self.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = progress.fractionCompleted;
        });
    };

    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [transferUtility enumerateToAssignBlocksForUploadTask:^(AWSS3TransferUtilityUploadTask * _Nonnull uploadTask, AWSS3TransferUtilityProgressBlock  _Nullable __autoreleasing * _Nullable uploadProgressBlockReference, AWSS3TransferUtilityUploadCompletionHandlerBlock  _Nullable __autoreleasing * _Nullable completionHandlerReference) {
        NSLog(@"%lu", (unsigned long)uploadTask.taskIdentifier);

        *uploadProgressBlockReference = weakSelf.progressBlock;
        *completionHandlerReference = weakSelf.completionHandler;

        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = @"Uploading...";
        });
    } downloadTask:nil];
}

-(NSString*)timeResult:(Float64)timeDate
{
    NSString *Text;
    int const minVideo= 94;
    
    NSLog(@"%f",timeDate);
    NSLog(@" Size of the File = %llu MB", FileSize);
    NSLog(@" Time Taken to upload = %f Seconds ",timeDate);
    NSLog(@" Time to be taken for 1MB = %f Seconds", timeDate / FileSize);
    NSLog(@" Time to be taken for `15 Sec` Video(94MB) = %f Seconds", minVideo*(timeDate / FileSize));
    NSLog(@" Time to be taken for `15 Sec` Video(94MB) = %f Minutes %d Seconds",(minVideo*(timeDate/FileSize))/60, (int)(minVideo*(timeDate/FileSize)) % 60);
    
    
    Text = [NSString stringWithFormat:@"Size of the File = %llu MB\n", FileSize];
    //Text = [ Text stringByAppendingString:[NSString stringWithFormat:@"Upload Speed = 100 Mbps \n "]];
    Text= [Text stringByAppendingString:[NSString stringWithFormat:@"Time Taken to upload = %f Seconds\n\n", timeDate ]];
    Text= [Text stringByAppendingString:[NSString stringWithFormat:@"Time to be taken for 1MB = %f Seconds\n\n", timeDate / FileSize ]];
    Text= [Text stringByAppendingString:[NSString stringWithFormat:@"Time to be taken for `15 Sec` 4k Video of size 94MB = %f Seconds ", minVideo*(timeDate / FileSize)]];
    Text= [Text stringByAppendingString:[NSString stringWithFormat:@"or %d Minutes %d Seconds \n \n ", (int)(minVideo*(timeDate/FileSize))/60, (int)(minVideo*(timeDate/FileSize)) % 60 ]];
    Text = [ Text stringByAppendingString:[NSString stringWithFormat:@" **********************************\n"]];
//    Text= [Text stringByAppendingString:[NSString stringWithFormat:@"The same 94mb may take only =%f Seconds in case of 1000 mbps \n\n", ((minVideo*(timeDate/FileSize))/10)]];
    Text = [ Text stringByAppendingString:[NSString stringWithFormat:@"Note:\n#1. Please check your bandwith speed manually\n#2. 15 Seconds of 4k video holds 94Mb of space"]];
    
    return Text;
}

- (IBAction)start:(id)sender {
    self.statusLabel.text = @"Started ...";
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // Create a test file in the temporary directory
//        NSMutableString *dataString = [NSMutableString new];
//        for (int32_t i = 1; i < 10000000; i++) {
//            [dataString appendFormat:@"%d\n", i];
//        }
//
//        [self uploadData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
//    });

    NSString *filePath =  [[NSBundle mainBundle] pathForResource:@"movie" ofType:@"mov"];
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSDictionary *attrs = [man attributesOfItemAtPath: filePath error: NULL];
    FileSize = [attrs fileSize]/1000000;
    
    NSData *videoData = [NSData dataWithContentsOfFile:filePath];
    NSLog(@"%lu",(unsigned long)videoData.length);
//    [self uploadData:videoData];

}

/**
 *  Uploding the given data to the given paramers to the S3 Amazon server.
 *
 *  @param reqVideoData video to be uploaded
 *  @param patientId    video to be uploaded on given patient id
 *  @param iteration    number of the video for the given patient
 *  @param videoUrl     video URL to be uploaded on the given URL
 *  @param timestamp    video was recorded at the given timpStamp
 */
- (void)uploadData:(NSData *)reqVideoData : (NSString*)patientId : (NSString*)iteration : (NSURL*)videoUrl : (NSString*)timestamp{
    NSLog(@"Patient ID : %@",patientId);
    
    NSLog(@"video: %@",videoUrl);

    __weak AWSBackgroundupload *weakSelf = self;
    self.completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"Error in uploading video : %@",error);
            } else {
                
                NSDictionary* dict = [NSDictionary dictionaryWithObject:videoUrl forKey:@"videoUrl"];
                NSLog(@"%@",dict);
                
                PFGlobalConstants *global = [[PFGlobalConstants alloc] init];
                NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];

                if([iteration isEqualToString:@"1"]){
                    NSString *urlString = [defaults objectForKey:@"awsURLOne"];
                    NSURL * url = [[NSURL alloc] initWithString:urlString];
                    [global videoStatus:url iteration:iteration];
                }
                else if([iteration isEqualToString:@"2"]){
                    NSString *urlString = [defaults objectForKey:@"awsURLTwo"];
                    NSURL * url = [[NSURL alloc] initWithString:urlString];
                    [global videoStatus:url iteration:iteration];
                }
                else if([iteration isEqualToString:@"3"]){
                    NSString *urlString = [defaults objectForKey:@"awsURLThree"];
                    NSURL * url = [[NSURL alloc] initWithString:urlString];
                    [global videoStatus:url iteration:iteration];
                }
                else if([iteration isEqualToString:@"4"]){
                    NSString *urlString = [defaults objectForKey:@"awsURLFour"];
                    NSURL * url = [[NSURL alloc] initWithString:urlString];
                    [global videoStatus:url iteration:iteration];

                }

              PFCameraviewcontrollerscreen *cam = [PFCameraviewcontrollerscreen alloc];
                [cam deleteTempVideo:videoUrl];

//                [[NSNotificationCenter defaultCenter]postNotificationName:@"showAlert" object:nil];

                NSLog(@"File uploaded successfully!");

                NSFileManager *fileManager = [NSFileManager defaultManager];

                BOOL success = [fileManager removeItemAtPath:[videoUrl absoluteString] error:NULL];
                

                if (success) {
                    NSLog(@"Video url deleted");
                }
            }
        });
    };

    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [transferUtility enumerateToAssignBlocksForUploadTask:^(AWSS3TransferUtilityUploadTask * _Nonnull uploadTask, AWSS3TransferUtilityProgressBlock  _Nullable __autoreleasing * _Nullable uploadProgressBlockReference, AWSS3TransferUtilityUploadCompletionHandlerBlock  _Nullable __autoreleasing * _Nullable completionHandlerReference) {
        NSLog(@"%lu", (unsigned long)uploadTask.taskIdentifier);

        *uploadProgressBlockReference = weakSelf.progressBlock;
        *completionHandlerReference = weakSelf.completionHandler;

        dispatch_async(dispatch_get_main_queue(), ^{
        });
    } downloadTask:nil];

    AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
    expression.progressBlock = self.progressBlock;

    startTime = [NSDate date];

    NSString *uploadFolderName = [NSString stringWithFormat:@"%@/%@/%@_%@_%@.MOV",patientId,timestamp,patientId,timestamp,iteration];
    [[transferUtility uploadData:reqVideoData
                          bucket:[PFGlobalConstants getS3BucketName]
                             key:uploadFolderName
                     contentType:@"binary/octet-stream"
                      expression:expression
                completionHander:self.completionHandler] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Error: %@", task.error);
        }
        if (task.exception) {
            NSLog(@"Exception: %@", task.exception);
        }
        if (task.result) {

            NSLog(@"Task result : %@",task.result);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Uploading ...");
            });
        }
        return nil;
    }];

}

/**
 *  Uploding the given data to the given paramers to the S3 Amazon server.
 *
 *  @param reqVideoData video to be uploaded
 *  @param patientId    video to be uploaded on given patient id
 *  @param iteration    number of the video for the given patient
 *  @param documentUrl  document URL to be uploaded on the given URL
 *  @param timestamp    document was recorded at the given timpStamp
 */
- (void)uploadData:(NSData *)reqVideoData : (NSString*)patientId : (NSString*)timestamp : (NSURL*)documentUrl{
    NSLog(@"Patient ID : %@",patientId);
    
    NSLog(@"video: %@",documentUrl);
    
    __weak AWSBackgroundupload *weakSelf = self;
    self.completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"Error in uploading video : %@",error);
            } else {
                
                PFCameraviewcontrollerscreen *cam = [PFCameraviewcontrollerscreen alloc];
                [cam deleteTempVideo:documentUrl];
                
                NSLog(@"File uploaded successfully!");
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                BOOL success = [fileManager removeItemAtPath:[documentUrl absoluteString] error:NULL];
                
                if (success) {
                    NSLog(@"Video url deleted");
                }
            }
        });
    };
    
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [transferUtility enumerateToAssignBlocksForUploadTask:^(AWSS3TransferUtilityUploadTask * _Nonnull uploadTask, AWSS3TransferUtilityProgressBlock  _Nullable __autoreleasing * _Nullable uploadProgressBlockReference, AWSS3TransferUtilityUploadCompletionHandlerBlock  _Nullable __autoreleasing * _Nullable completionHandlerReference) {
        NSLog(@"%lu", (unsigned long)uploadTask.taskIdentifier);
        
        *uploadProgressBlockReference = weakSelf.progressBlock;
        *completionHandlerReference = weakSelf.completionHandler;
        
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    } downloadTask:nil];
    
    AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
    expression.progressBlock = self.progressBlock;
    
    startTime = [NSDate date];
    
    NSString *uploadFolderName = [NSString stringWithFormat:@"%@/%@/%@_%@.jpg",patientId,timestamp,patientId,timestamp];
    [[transferUtility uploadData:reqVideoData
                          bucket:[PFGlobalConstants getS3BucketName]
                             key:uploadFolderName
                     contentType:@"binary/octet-stream"
                      expression:expression
                completionHander:self.completionHandler] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Error: %@", task.error);
        }
        if (task.exception) {
            NSLog(@"Exception: %@", task.exception);
        }
        if (task.result) {
            
            NSLog(@"Task result : %@",task.result);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Uploading ...");
            });
        }
        return nil;
    }];
    
}

@end

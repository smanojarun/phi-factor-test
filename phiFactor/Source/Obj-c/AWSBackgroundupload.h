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

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>


@interface AWSBackgroundupload : UIViewController{
    unsigned long long FileSize;
}

@property (nonatomic,weak) IBOutlet UITextView *resultView;

@property (copy, nonatomic) AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler;
@property (copy, nonatomic) AWSS3TransferUtilityProgressBlock progressBlock;


- (void)uploadData:(NSData *)reqVideoData : (NSString*)patientId : (NSString*)iteration : (NSURL*)videoUrl : (NSString*)timestamp;

- (void)uploadData:(NSData *)reqVideoData : (NSString*)patientId : (NSString*)timestamp : (NSURL*)documentUrl;
@end

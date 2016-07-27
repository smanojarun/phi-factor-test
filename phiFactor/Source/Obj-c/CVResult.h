//
//  NSObject+CVResult.h
//  PhiFactor
//
//  Created by Hubino on 5/31/16.
//  Copyright © 2016 Hubino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CVResult : NSObject{

    NSString * Casecafefile;
    NSString * Modelfile;
    NSString * Modelfile1;
    NSString * Modelfile2;
    NSString * imagepath;
    NSString * eyepath;
    int validateVideo;
}

-(int*)getErrorCode :(UIImage *)previewImage : (NSInteger)videoCount : (NSInteger)retakeCount :(BOOL) isResizable;

-(int)getVideoResult :(NSURL *)videoURL  : (NSInteger)videoCount;

-(int)loadModelFile;

@end

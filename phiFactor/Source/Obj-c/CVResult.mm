//
//  NSObject+CVResult.m
//  PhiFactor
//
//  Created by Hubino on 5/31/16.
//  Copyright © 2016 Hubino. All rights reserved.
//

#import "CVResult.h"
#import <AssetsLibrary/AssetsLibrary.h>
#include "FaceDetection.h"
#include <opencv2/opencv.hpp>
#include <stdio.h>

@implementation CVResult
/**
 *  Creating instance for CVResult class
 *
 *  @return int value.
 */
-(int)loadModelFile{

    Casecafefile = [[NSBundle mainBundle]
                    pathForResource:@"CV_algos/model/algoBucket_facefinder_v_1_0"
                    ofType:@"xml"];
    eyepath=[[NSBundle mainBundle]
             pathForResource:@"CV_algos/model/algoBucket_eyepair_check_v_1_0"
             ofType:@"xml"];
    Modelfile = [[NSBundle mainBundle]
                 pathForResource:@"CV_algos/model/main_ccnf_general"
                 ofType:@"txt"];
    Modelfile1 = [[NSBundle mainBundle]
                  pathForResource:@"CV_algos/model/tris_68_full"
                  ofType:@"txt"];
    Modelfile2=[[NSBundle mainBundle]
                pathForResource:@"CV_algos/AU_predictors/AU_all_best"
                ofType:@"txt"];


    std::string str_modelfile=[Modelfile UTF8String];
    std::string str_modelfile1=[Modelfile1 UTF8String];
    std::string str_modelfile2=[Modelfile2 UTF8String];
    std::string str_xmlpath=[Casecafefile UTF8String];
    std::string str_eyepath=[eyepath UTF8String];

    algobucket dlb;

    int res=dlb.ModelLoading(str_modelfile,str_modelfile1,str_modelfile2,str_xmlpath,str_eyepath);

    return res;

}

/**
 *  Loading the UIImage to CVResult Class and getting the error and response code for the given image
 *
 *  @param previewImage Image to be analyed and generate error code.
 *  @param videoCount   number of the video is recording
 *  @param retakeCount  retake count of the video
 *  @param isResizable  If its true given image to be resized.
 *
 *  @return error code.
 */

-(int*)getErrorCode :(UIImage *)previewImage  : (NSInteger)videoCount : (NSInteger)retakeCount :(BOOL) isResizable{

    NSLog(@"Video count : %ld",(long)videoCount);

    cv::Mat matImage = [self cvMatFromUIImage:previewImage];


    algobucket dlb;
    int *facerect=new int[13];
     int *logvalue=new int[15];
    cv::Mat output;
    cv :: cvtColor(matImage, matImage, CV_BGR2RGB);
    
    if(isResizable == true)
    {
//        cv::resize(matImage, matImage, cv::Size(matImage.cols/4,matImage.rows/4));
    }
    else
    {
        //cv::resize(matImage, matImage, cv::Size(matImage.cols/2,matImage.rows/2));
    }

    int res=dlb.FaceQualityCheck(matImage, output, facerect, 13,videoCount,0,retakeCount,logvalue);

    int errorCode = 0;
    for(unsigned int i = 0; i < 13; i++)
    {
        NSLog(@"Error code : %d",facerect[i]);
    }
    for(unsigned int p = 0; p < 15; p++)
    {
        NSLog(@"log values  : %d",logvalue[p]);
    }
    
    
    if(output.channels() == 3)
    {
        cv :: cvtColor(output, output, CV_BGR2RGB);
    }

    cv::Mat cvImage=output.clone();

    UIImage *outputImage = [self UIImageFromCVMat:cvImage];
    NSData *imageData = UIImagePNGRepresentation(outputImage);

    NSDictionary* dict = [NSDictionary dictionaryWithObject:
                          imageData
                                                     forKey:@"dataImage"];

    [[NSNotificationCenter defaultCenter]postNotificationName:@"showPreviewImage" object:nil userInfo:dict];

    return facerect;

}

-(int)getVideoResult :(NSURL *)videoURL : (NSInteger)videoCount{


    algobucket dlb;

    NSString *reqURLstr = [videoURL path];

    std::string v_path=[reqURLstr UTF8String];

    cv::VideoCapture cap(v_path.c_str());
    if(cap.isOpened())
    {
        std::cout<<"opENDED"<<std::endl;;
    }
    int rec_des=0;
    static int v=0;
    while(true && !rec_des){

        rec_des=0;
        std::cout<<"enter loop  "<<std::endl;
        cv::Mat image;

        cap.read(image);


//        if(image.empty() && v==0)
//        {
//            cap.read(image);
//            v++;
//        }
        if(!image.empty())
        {

            cv::transpose(image, image);
            cv::flip(image, image, 1);
            // cv::cvtColor(image, image, cv::Size(360,640));
            cv::resize(image, image, cv::Size(image.cols/2,image.rows/2));
            if(image.channels()==3)
            {
                cv::cvtColor(image, image, CV_BGR2RGB);
            }
            UIImage *cvImage = [self UIImageFromCVMat:image];
        int *facerect=new int[13];
         int *logvalue=new int[15];
        cv::Mat output;

        int res=dlb.FaceQualityCheck(image, output, facerect, 13,videoCount,1,0,logvalue);

        int errorCode = 0;
        for(unsigned int i = 0; i < 13; i++)
        {
            NSLog(@"Error code : %d",facerect[i]);
        }

        if(res==1008)
            {
                NSLog(@"1008 ----- Error code");

            }
        if(facerect[6] == 0) {
            self->validateVideo = 0;
        }
        else{
            self->validateVideo = 1;

        }
        }
        else{
            rec_des=1;
            //return validateVideo;
           // break;
        }

    }

    return validateVideo;

}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;

    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );


    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;

    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)

    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags

    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

@end

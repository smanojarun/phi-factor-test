/*
 * File:   Poseestimation.h
 * Author: hubino
 *
 * Created on 8 September, 2015, 2:18 PM
 */
#include <iostream>
#import <opencv2/opencv.hpp>

class algobucket
{
public:
    int FaceQualityCheck(cv::Mat input,cv::Mat &output,int *FaceRect,int limit1,int v_option,int type_source,int retake_count,int *logvalue);

    int ModelLoading(std::string model_path="",std::string model_extrapath="",std::string model_extrapath1="",std::string xml_path="",std::string eye_path="");
};
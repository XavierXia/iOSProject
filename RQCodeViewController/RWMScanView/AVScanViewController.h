//
//  ScanViewController.h
//  tdx
//
//  Created by xiawenxing on 15-5-18.
//  Copyright (c) 2015年 tdx.com.iPhone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "viewPassValueDelegate.h"

@interface AVScanViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) UIImageView * line;
@property (nonatomic, retain) NSObject<viewPassValueDelegate>* passValueDelegate;
@property (strong,nonatomic) AVCaptureDevice * device;
@property (strong,nonatomic) AVCaptureDeviceInput * input;
@property (strong,nonatomic) AVCaptureMetadataOutput * output;
@property (strong,nonatomic) AVCaptureSession * session;
@property (strong,nonatomic) AVCaptureVideoPreviewLayer * preview;

@end

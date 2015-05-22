//
//  ScanViewController.h
//  tdx
//
//  Created by xiawenxing on 15-5-18.
//  Copyright (c) 2015年 tdx.com.iPhone. All rights reserved.
//

#import "ZBarReaderViewController.h"
#import "viewPassValueDelegate.h"

@interface ScanViewController : ZBarReaderViewController <ZBarReaderDelegate>

@property (nonatomic, strong) UIImageView * line;
@property (nonatomic, retain) NSObject<viewPassValueDelegate>* passValueDelegate;

@end

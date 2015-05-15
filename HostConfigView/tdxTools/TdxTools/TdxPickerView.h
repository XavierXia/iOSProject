//
//  TdxTaAPI.h
//  tdxZZHL
//
//  Created by tdxmac2 on 15/5/4.
//  Copyright (c) 2015年 tdx.com.iPhone. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "UIViewPassValueDelegate.h"

@interface TdxPickerView : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic, strong) NSMutableArray *pickerData;
@property(nonatomic, retain) NSObject<UIViewPassValueDelegate>* delegate;

@end
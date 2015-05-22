//
//  ScanViewController.m
//  tdx
//
//  Created by xiawenxing on 15-5-18.
//  Copyright (c) 2015年 tdx.com.iPhone. All rights reserved.
//

#import "ScanViewController.h"

@interface ScanViewController ()
{
    int num;
    BOOL downOfLine;
    NSTimer * timer;
    
    UIButton* m_leftButton;
}

@end

@implementation ScanViewController
@synthesize line;
@synthesize passValueDelegate;

- (id) init
{
    self = [super init];
    num = 0;
    downOfLine = YES;
    self.wantsFullScreenLayout = YES;
    self.showsZBarControls = NO;
    self.supportedOrientationsMask = ZBarOrientationMaskAll;
    self.readerDelegate = self;
    [self.scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    [self setOverLayPickerView];
    return self;
}

- (void)setOverLayPickerView
{
    UIView* up = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    up.alpha = 0.3;
    up.backgroundColor = [UIColor blackColor];
    [self.view addSubview:up];
    
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 20, 280)];
    left.alpha = 0.3;
    left.backgroundColor = [UIColor blackColor];
    [self.view addSubview:left];
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(300, 80, 20, 280)];
    right.alpha = 0.3;
    right.backgroundColor = [UIColor blackColor];
    [self.view addSubview:right];
    
    UIView * down = [[UIView alloc] initWithFrame:CGRectMake(0, 360, 320, 220)];
    down.alpha = 0.3;
    down.backgroundColor = [UIColor blackColor];
    [self.view addSubview:down];
    
    //添加扫描线
    UIImageView * image = [[UIImageView alloc] init];
    image.frame = CGRectMake(20, 80, 280, 280);
    [self.view addSubview:image];
    
    line = [[UIImageView alloc] initWithFrame:CGRectMake(30, 10, 220, 2)];
    line.image = [UIImage imageNamed:@"line.png"];
    [image addSubview:line];
    
    //添加扫描边框
    UIImageView *image_re = [[UIImageView alloc] init];
    image_re.frame = CGRectMake(20, 80, 280, 280);
    image_re.image = [UIImage imageNamed:@"white_rectangle.png"];
    [self.view addSubview:image_re];
    
    UIImageView *image_corner = [[UIImageView alloc] init];
    image_corner.frame = CGRectMake(20, 80, 280, 280);
    image_corner.image = [UIImage imageNamed:@"green_four_corner.png"];
    [self.view addSubview:image_corner];
    
    //返回按钮，标题栏
    m_leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    m_leftButton.frame = CGRectMake(0.0, 0.0, 40.0, 27.0);
    [m_leftButton setImage:[UIImage imageNamed:@"navbar_back"] forState:UIControlStateNormal];
    m_leftButton.backgroundColor = [UIColor lightGrayColor];
    [m_leftButton addTarget:self action:@selector(buttonBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:m_leftButton];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
    self.navigationItem.title = @"二维码扫描";
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 380, 280, 40)];
    label.text = @"将二维码放入框内，即可自动扫描";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    
    //定时器，设定时间过1.5秒，
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    
}

- (void)animation
{
    if (downOfLine == YES) {
        num ++;
        line.frame = CGRectMake(30, 10+2*num, 220, 2);
        if (2*num == 260) {
            downOfLine = NO;
        }
    }
    else {
        num = 0;
        line.frame = CGRectMake(30, 10+2*num, 220, 2);
        downOfLine = YES;
    }
}

- (void)buttonBack
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    [timer invalidate];
    [passValueDelegate passValue:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [timer invalidate];
    line.frame = CGRectMake(30, 10, 220, 2);
    num = 0;
    downOfLine = YES;
    
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol * symbol = nil;
    for(symbol in results)
        break;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    //NSData * scanData = [symbol.data dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString * result;
    if ([symbol.data canBeConvertedToEncoding:NSShiftJISStringEncoding])
        
    {
        result = [NSString stringWithCString:[symbol.data cStringUsingEncoding: NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
    }
    else
    {
        result = symbol.data;
    }

    if (result == nil ) {
        UIAlertView * failAlert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无效二维码" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
        [failAlert show];
        return;
    }
    
    [passValueDelegate passValue:result];
    [self.navigationController popViewControllerAnimated:YES];
}
@end

//
//  AVScanViewController.m
//  tdx
//
//  Created by xiawenxing on 15-5-18.
//  Copyright (c) 2015年 tdx.com.iPhone. All rights reserved.
//

#import "AVScanViewController.h"

@interface AVScanViewController ()
{
    int num;
    BOOL downOfLine;
    NSTimer * timer;
    
    UIButton* m_leftButton;
}
@end

@implementation AVScanViewController
@synthesize line;
@synthesize passValueDelegate;
@synthesize device;
@synthesize input;
@synthesize output;
@synthesize session;
@synthesize preview;

- (id) init
{
    self = [super init];
    self.edgesForExtendedLayout = YES;
    [self setOverLayPickerView];
    return self;
}

- (void)setOverLayPickerView
{
    num = 0;
    downOfLine = YES;
    UIView* up = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    up.alpha = 0.3;
    up.backgroundColor = [UIColor blackColor];
    [self.view addSubview:up];
    
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 20, 280)];
    left.alpha = 0.3;
    left.backgroundColor = [UIColor blackColor];
    [self.view addSubview:left];
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(300, 60, 20, 280)];
    right.alpha = 0.3;
    right.backgroundColor = [UIColor blackColor];
    [self.view addSubview:right];
    
    UIView * down = [[UIView alloc] initWithFrame:CGRectMake(0, 340, 320, 240)];
    down.alpha = 0.3;
    down.backgroundColor = [UIColor blackColor];
    [self.view addSubview:down];
    
    //添加扫描线
    UIImageView * image = [[UIImageView alloc] init];
    image.frame = CGRectMake(20, 60, 280, 280);
    [self.view addSubview:image];
    
    line = [[UIImageView alloc] initWithFrame:CGRectMake(30, 10, 220, 2)];
    line.image = [UIImage imageNamed:@"line.png"];
    [image addSubview:line];
    
    //添加扫描边框
    UIImageView *image_re = [[UIImageView alloc] init];
    image_re.frame = CGRectMake(20, 60, 280, 280);
    image_re.image = [UIImage imageNamed:@"white_rectangle.png"];
    [self.view addSubview:image_re];
    
    UIImageView *image_corner = [[UIImageView alloc] init];
    image_corner.frame = CGRectMake(20, 60, 280, 280);
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
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 360, 280, 40)];
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

-(void)viewWillAppear:(BOOL)animated
{
    [self setupCamera];
}

- (void)setupCamera
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    // Device
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    //Output
    output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [output setRectOfInterest:CGRectMake(60.0/size.height, 20.0/size.width, 280.0/size.height, 280.0/size.width)];
    
    // Session
    session = [[AVCaptureSession alloc]init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([session canAddInput:self.input])
    {
        [session addInput:self.input];
    }
    
    if ([session canAddOutput:self.output])
    {
        [session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // preview.frame =CGRectMake(0, 0, 320, 548);
    
    preview.frame =CGRectMake(0, 0, size.width, size.height);
    [self.view.layer insertSublayer:self.preview atIndex:0];

    // Start
    [session startRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [session stopRunning];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [timer invalidate];
    //NSLog(@"--stringValue：%@",stringValue);

    if (stringValue == nil ) {
        UIAlertView * failAlert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无效二维码" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
        [failAlert show];
        return;
    }
    //扫描成功，返回扫描值，并返回上一个view
    [passValueDelegate passValue:stringValue];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  TdxPickerView.m
//  tdxZZHL
//
//  Created by xiawenxing on 15/5/7.
//  Copyright (c) 2015年 tdx.com.iPhone. All rights reserved.
//
#import "TdxPickerView.h"

@interface TdxPickerView ()
{
    UIPickerView *pickerView;
    UIButton *selectButton;
}

@end

@implementation TdxPickerView
@synthesize pickerData;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 20, 320, 216)];
    pickerView.delegate=self;
    //显示选中框
    pickerView.showsSelectionIndicator=YES;
    [self.view addSubview:pickerView];
    
    //添加按钮
    selectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    selectButton.frame = CGRectMake(120, 250, 80, 40);
    
    [selectButton setTitle:@"选择" forState:UIControlStateNormal];
    [selectButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:selectButton];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    pickerData = nil;
    pickerView = nil;
}


-(void) buttonPressed:(id)sender
{
    NSInteger row =[pickerView selectedRowInComponent:0];
    [delegate passValue:[pickerData objectAtIndex:row]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Picker Date Source Methods
//返回显示的列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
//返回当前列显示的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerData count];
}

#pragma mark Picker Delegate Methods

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [pickerData objectAtIndex:row];
}

@end

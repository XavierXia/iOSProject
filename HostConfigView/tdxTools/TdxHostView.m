//
//  TdxHostView.h
//  tdxZZHL
//
//  Created by xiawenxing on 15/5/4.
//  Copyright (c) 2015年 tdx.com.iPhone. All rights reserved.
//
#import "TdxHostView.h"
#import "TdxMacroDefinition.h"

@interface TdxHostView () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    UIButton *m_leftButton;
    UITableView*    m_table;
    
    //textfield
    UILabel *m_labelHostID;
    UITextField *m_textFieldName;
    UITextField *m_textFieldHostAddr;
    UITextField *m_textFieldHostPort;
    UITextField *m_textFieldHostCN;
    
    UISwitch *m_balanceSwitch;
    UISlider *m_sliderWeightFactor;
    UILabel *m_labelWeightFactor;
}
@end

@implementation TdxHostView
@synthesize m_DicHost;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 左边按钮（返回）
    m_leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    m_leftButton.frame = CGRectMake(0.0, 0.0, 40.0, 27.0);
    [m_leftButton setImage:[UIImage imageNamed:@"navbar_back"] forState:UIControlStateNormal];
    [m_leftButton setImage:[UIImage imageNamed:@"navbar_back_p"] forState:UIControlStateSelected];
    m_leftButton.backgroundColor = [UIColor lightGrayColor];
    [m_leftButton addTarget:self action:@selector(buttonBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:m_leftButton];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
    self.navigationItem.title = @"Host参数设置";
    
    CGRect rect = self.view.frame;
    rect.origin.y=0;
    rect.size.height = rect.size.height - SysNavbarHeight;
    float fversion=[[[UIDevice currentDevice]systemVersion] floatValue];
    if(fversion>=7.0)
    {
        rect.size.height= rect.size.height - 20;
    }
    
    m_table = [[UITableView alloc] initWithFrame:rect];
    m_table.delegate = self;
    m_table.dataSource = self;
    m_table.separatorStyle = UITableViewCellSeparatorStyleNone; // 无分隔线
    m_table.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:243.0/255.0 blue:238.0/255.0 alpha:1.0];
    
    [self.view addSubview:m_table];
}


- (IBAction)buttonBack:(id)sender
{
    //退出之前保存设置参数
    [m_DicHost setObject:m_textFieldName.text forKey:@"Name"];
    [m_DicHost setObject:m_textFieldHostAddr.text forKey:@"Addr"];
    [m_DicHost setObject:m_textFieldHostPort.text forKey:@"Port"];
    [m_DicHost setObject:m_textFieldHostCN.text forKey:@"CN"];
    
    //NSLog(@"----buttonBack, m_DicHost:%@",m_DicHost);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - miss keyboard
-(void)dismissKeyboard
{
    [m_textFieldHostAddr resignFirstResponder];
    [m_textFieldHostCN resignFirstResponder];
    [m_textFieldHostPort resignFirstResponder];
    [m_textFieldName resignFirstResponder];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [m_DicHost count] + 1;
}

//响应slider动作
-(void) sliderValueChange:(id)sender
{
    NSString *value = [NSString stringWithFormat:@"%d",(int)[m_sliderWeightFactor value]];
    m_labelWeightFactor.text = value;
    [m_DicHost setObject:value forKey:@"WeightFactor"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell:%ld,%ld", (long)[indexPath section], (long)[indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIColor* cellseparatorlinecolor=[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        switch(indexPath.row)
        {
            {
            case 0:
                {
                    cell.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:243.0/255.0 blue:238.0/255.0 alpha:1.0];
                    
                    UILabel *bottomlabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, UITABLEVIEWCELL_SECTION_HEIGHT-1,cell.contentView.frame.size.width, 1)];
                    bottomlabel.backgroundColor=cellseparatorlinecolor;
                    [cell addSubview:bottomlabel];
                    break;
                }
            case 1:
                {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(UIMARGIN_LEFT * 2, (UITABLEVIEWCELL_HEIGHT - UILABEL_HEIGHT) / 2, 80.0f,UILABEL_HEIGHT)];
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = [UIColor grayColor];
                    label.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    label.text = @"Host ID: ";
                    [cell addSubview:label];
                    
                    m_labelHostID = [[UILabel alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - UIMARGIN_LEFT * 3 - 200.0f, (UITABLEVIEWCELL_HEIGHT - UITEXTFIELD_HEIGHT) / 2, 200, UITEXTFIELD_HEIGHT)];
                    m_labelHostID.backgroundColor = [UIColor clearColor];
                    m_labelHostID.textColor = [UIColor grayColor];
                    m_labelHostID.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    m_labelHostID.text = [m_DicHost objectForKey:@"ID"];
                    [cell addSubview:m_labelHostID];
                    
                    UIView *tempView = [[UIView alloc] init];
                    tempView.backgroundColor = [UIColor whiteColor];
                    [cell setBackgroundView:tempView];
                    
                    UILabel *bottomlabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, UITABLEVIEWCELL_HEIGHT-1,cell.contentView.frame.size.width, 1)];
                    bottomlabel.backgroundColor=cellseparatorlinecolor;
                    [cell addSubview:bottomlabel];
                    break;
                }
            case 2:
                {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(UIMARGIN_LEFT * 2, (UITABLEVIEWCELL_HEIGHT - UILABEL_HEIGHT) / 2, 80.0f,UILABEL_HEIGHT)];
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = [UIColor grayColor];
                    label.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    label.text = @"Name: ";
                    [cell addSubview:label];
                    
                    m_textFieldName = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - UIMARGIN_LEFT * 3 - 200.0f, (UITABLEVIEWCELL_HEIGHT - UITEXTFIELD_HEIGHT) / 2, 200, UITEXTFIELD_HEIGHT)];
                    m_textFieldName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    m_textFieldName.textAlignment = NSTextAlignmentLeft;
                    m_textFieldName.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    m_textFieldName.textColor = [UIColor grayColor];
                    m_textFieldName.autocorrectionType = UITextAutocorrectionTypeNo;
                    m_textFieldName.clearButtonMode = UITextFieldViewModeWhileEditing;
                    m_textFieldName.delegate = self;
                    m_textFieldName.text = [m_DicHost objectForKey:@"Name"];
                    
                    [cell addSubview:m_textFieldName];
                    
                    UIView *tempView = [[UIView alloc] init];
                    tempView.backgroundColor = [UIColor whiteColor];
                    [cell setBackgroundView:tempView];
                    
                    UILabel *bottomlabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, UITABLEVIEWCELL_HEIGHT-1,cell.contentView.frame.size.width, 1)];
                    bottomlabel.backgroundColor=cellseparatorlinecolor;
                    [cell addSubview:bottomlabel];
                    break;
                }
            case 3:
                {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(UIMARGIN_LEFT * 2, (UITABLEVIEWCELL_HEIGHT - UILABEL_HEIGHT) / 2, 80.0f,UILABEL_HEIGHT)];
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = [UIColor grayColor];
                    label.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    label.text = @"IP Addr: ";
                    [cell addSubview:label];
                    
                    m_textFieldHostAddr = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - UIMARGIN_LEFT * 3 - 200.0f, (UITABLEVIEWCELL_HEIGHT - UITEXTFIELD_HEIGHT) / 2, 200, UITEXTFIELD_HEIGHT)];
                    m_textFieldHostAddr.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    m_textFieldHostAddr.textAlignment = NSTextAlignmentLeft;
                    m_textFieldHostAddr.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    m_textFieldHostAddr.textColor = [UIColor grayColor];
                    m_textFieldHostAddr.autocorrectionType = UITextAutocorrectionTypeNo;
                    m_textFieldHostAddr.clearButtonMode = UITextFieldViewModeWhileEditing;
                    m_textFieldHostAddr.delegate = self;
                    m_textFieldHostAddr.text = [m_DicHost objectForKey:@"Addr"];
                    m_textFieldHostAddr.keyboardType = UIKeyboardTypeDecimalPad;
                    
                    [cell addSubview:m_textFieldHostAddr];
                    
                    UIView *tempView = [[UIView alloc] init];
                    tempView.backgroundColor = [UIColor whiteColor];
                    [cell setBackgroundView:tempView];
                    
                    UILabel *bottomlabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, UITABLEVIEWCELL_HEIGHT-1,cell.contentView.frame.size.width, 1)];
                    bottomlabel.backgroundColor=cellseparatorlinecolor;
                    [cell addSubview:bottomlabel];
                    break;
                }
            case 4:
                {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(UIMARGIN_LEFT * 2, (UITABLEVIEWCELL_HEIGHT - UILABEL_HEIGHT) / 2, 80.0f,UILABEL_HEIGHT)];
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = [UIColor grayColor];
                    label.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    label.text = @"Port: ";
                    [cell addSubview:label];
                    
                    m_textFieldHostPort = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - UIMARGIN_LEFT * 3 - 200.0f, (UITABLEVIEWCELL_HEIGHT - UITEXTFIELD_HEIGHT) / 2, 200, UITEXTFIELD_HEIGHT)];
                    m_textFieldHostPort.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    m_textFieldHostPort.textAlignment = NSTextAlignmentLeft;
                    m_textFieldHostPort.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    m_textFieldHostPort.textColor = [UIColor grayColor];
                    m_textFieldHostPort.autocorrectionType = UITextAutocorrectionTypeNo;
                    m_textFieldHostPort.clearButtonMode = UITextFieldViewModeWhileEditing;
                    m_textFieldHostPort.delegate = self;
                    m_textFieldHostPort.text = [m_DicHost objectForKey:@"Port"];
                    m_textFieldHostPort.keyboardType = UIKeyboardTypeNumberPad;
                    
                    [cell addSubview:m_textFieldHostPort];

                    UIView *tempView = [[UIView alloc] init];
                    tempView.backgroundColor = [UIColor whiteColor];
                    [cell setBackgroundView:tempView];
                    
                    UILabel *bottomlabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, UITABLEVIEWCELL_HEIGHT-1,cell.contentView.frame.size.width, 1)];
                    bottomlabel.backgroundColor=cellseparatorlinecolor;
                    [cell addSubview:bottomlabel];
                    break;
                }
            case 5:
                {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(UIMARGIN_LEFT * 2, (UITABLEVIEWCELL_HEIGHT - UILABEL_HEIGHT) / 2, 110.0f,UILABEL_HEIGHT)];
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = [UIColor grayColor];
                    label.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    label.text = @"WeightFactor: ";
                    [cell addSubview:label];
                    
                    m_labelWeightFactor = [[UILabel alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - UIMARGIN_LEFT * 3 - 200.0f+40.0f, (UITABLEVIEWCELL_HEIGHT - UITEXTFIELD_HEIGHT) / 2, 80, UITEXTFIELD_HEIGHT)];
                    m_labelWeightFactor.backgroundColor = [UIColor clearColor];
                    m_labelWeightFactor.textColor = [UIColor grayColor];
                    m_labelWeightFactor.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    m_labelWeightFactor.text = [m_DicHost objectForKey:@"WeightFactor"];
                    [cell addSubview:m_labelWeightFactor];
                    
                    m_sliderWeightFactor = [[UISlider alloc]initWithFrame:CGRectMake(cell.contentView.frame.size.width - UIMARGIN_LEFT * 4 - 200.0f +80, (UITABLEVIEWCELL_HEIGHT - SLIDER_HEIGHT) / 2, 130, 20.0f)];
                    m_sliderWeightFactor.maximumValue = 100;
                    m_sliderWeightFactor.minimumValue = 0;
                    m_sliderWeightFactor.value = [[m_DicHost objectForKey:@"WeightFactor"] intValue];
                    [m_sliderWeightFactor addTarget:self action:@selector(sliderValueChange:) forControlEvents:(UIControlEventValueChanged)];
                    [cell addSubview:m_sliderWeightFactor];
                    
                    UIView *tempView = [[UIView alloc] init];
                    tempView.backgroundColor = [UIColor whiteColor];
                    [cell setBackgroundView:tempView];
                    
                    UILabel *bottomlabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, UITABLEVIEWCELL_HEIGHT-1,cell.contentView.frame.size.width, 1)];
                    bottomlabel.backgroundColor=cellseparatorlinecolor;
                    [cell addSubview:bottomlabel];
                    break;
                }
            case 6:
                {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(UIMARGIN_LEFT * 2, (UITABLEVIEWCELL_HEIGHT - UILABEL_HEIGHT) / 2, 80.0f,UILABEL_HEIGHT)];
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = [UIColor grayColor];
                    label.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    label.text = @"CN: ";
                    [cell addSubview:label];
                    
                    m_textFieldHostCN = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - UIMARGIN_LEFT * 3 - 200.0f, (UITABLEVIEWCELL_HEIGHT - UITEXTFIELD_HEIGHT) / 2, 200, UITEXTFIELD_HEIGHT)];
                    m_textFieldHostCN.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    m_textFieldHostCN.textAlignment = NSTextAlignmentLeft;
                    m_textFieldHostCN.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    m_textFieldHostCN.textColor = [UIColor grayColor];
                    m_textFieldHostCN.autocorrectionType = UITextAutocorrectionTypeNo;
                    m_textFieldHostCN.clearButtonMode = UITextFieldViewModeWhileEditing;
                    m_textFieldHostCN.delegate = self;
                    m_textFieldHostCN.text = [m_DicHost objectForKey:@"CN"];
                    m_textFieldHostCN.keyboardType = UIKeyboardTypeNumberPad;
                    
                    [cell addSubview:m_textFieldHostCN];
                    
                    UIView *tempView = [[UIView alloc] init];
                    tempView.backgroundColor = [UIColor whiteColor];
                    [cell setBackgroundView:tempView];
                    
                    UILabel *bottomlabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, UITABLEVIEWCELL_HEIGHT-1,cell.contentView.frame.size.width, 1)];
                    bottomlabel.backgroundColor=cellseparatorlinecolor;
                    [cell addSubview:bottomlabel];
                    break;
                }
            default:
                    break;
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return UITABLEVIEWCELL_SECTION_HEIGHT;
        default:
            return UITABLEVIEWCELL_HEIGHT;
    }
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissKeyboard];
    return indexPath;
}


#pragma mark - TableView delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // return NO to not change text
    
    return YES;
}

//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [m_table setContentOffset:CGPointMake(0, 70) animated:YES];
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [m_table setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end
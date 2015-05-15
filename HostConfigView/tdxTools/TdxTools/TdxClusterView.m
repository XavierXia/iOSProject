//
//  TdxCluster.m
//  tdxZZHL
//
//  Created by xiawenxing on 15/5/4.
//  Copyright (c) 2015年 tdx.com.iPhone. All rights reserved.
//
#import "TdxClusterView.h"
#import "TdxHostView.h"
#import "TdxMacroDefinition.h"

@interface TdxClusterView () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate>
{

    NSMutableArray* m_ArrCluster;
    NSMutableArray* m_ArrClusterHost;
    UIButton *m_leftButton;
    UITableView*    m_table;
    UITableViewCellEditingStyle editingState;
    
    UILabel *m_labelClusterID;
    UITextField *m_textFieldName;
    UITextField *m_textFieldDefHost;
    UITextField *m_textFieldBalance;
    UIButton *m_addButton;
    UIButton *m_deleteButton;
    
    UISwitch *m_balanceSwitch;
    NSString * m_newAddHostIDStr;
    NSMutableDictionary* m_newDicHost;
    
    NSInteger rowNum;
    TdxHostView *hostView;
}
@end

@implementation TdxClusterView
@synthesize m_DicClusterAndHost;

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
    self.navigationItem.title = @"Cluster参数设置";
    
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
    
    NSString *key = [m_DicClusterAndHost objectForKey:@"ID"];
    m_ArrClusterHost = [m_DicClusterAndHost objectForKey:key];
    //NSLog(@"----------come in viewDidLoad,m_DicClusterAndHost:%@",m_DicClusterAndHost);
}

-(BOOL) checkHostParameter
{
    int m_ArrHostNum = [m_ArrClusterHost count];
    NSMutableSet *muSet = [NSMutableSet setWithCapacity:6];
    for (int i = 0; i< m_ArrHostNum; i++)
    {
        [muSet addObject:[[m_ArrClusterHost objectAtIndex:i] objectForKey:@"ID"]];
        
        //对HostView中的参数进行校验
        if ([[[m_ArrClusterHost objectAtIndex:i] objectForKey:@"Addr"] isEqual:@""])
        {
            return YES;
        }
        
        if ([[[m_ArrClusterHost objectAtIndex:i] objectForKey:@"Name"] isEqual:@""])
        {
            return YES;
        }
        
        if ([[[m_ArrClusterHost objectAtIndex:i] objectForKey:@"Port"] isEqual:@""])
        {
            return YES;
        }
    }
    
    if ([muSet count] != m_ArrHostNum)
    {
        return YES;
    }
    
    if(![muSet containsObject:[m_DicClusterAndHost objectForKey:@"DefHost"]])
    {
        return YES;
    }
    
    return NO;
}

-(BOOL) calibrateParameter
{
    if ([[m_DicClusterAndHost objectForKey:@"Name"] isEqual:@""])
    {
        return NO;
    }
    
    if ([[m_DicClusterAndHost objectForKey:@"DefHost"] isEqual:@""])
    {
        return NO;
    }
    
    if ([self checkHostParameter])
    {
        return NO;
    }
    
    return YES;
}

- (IBAction)buttonBack:(id)sender
{
    //退出前 保存设置的参数
    [m_DicClusterAndHost setObject:m_textFieldName.text forKey:@"Name"];
    [m_DicClusterAndHost setObject:m_textFieldDefHost.text forKey:@"DefHost"];
    
    //进行有效性校验
    if ([self calibrateParameter])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else //参数的有效性校验失败
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请把参数填写完整或正确" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)dealloc
{
}

-(void)viewWillAppear:(BOOL)animated
{
    [m_table reloadData];
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
    [m_textFieldBalance resignFirstResponder];
    [m_textFieldDefHost resignFirstResponder];
    [m_textFieldName resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //NSLog(@"----numberOfSectionsInTableView :%d",1);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger clusterNum = m_DicClusterAndHost.count - 1;
    NSString *key = [m_DicClusterAndHost objectForKey:@"ID"];
    NSInteger clusterAndHostNum = [[m_DicClusterAndHost objectForKey:key] count];
    rowNum = clusterNum + clusterAndHostNum + 3;
    //NSLog(@"----numberOfRowsInSection ,rowNum:%d",rowNum);
    return rowNum;
}

//响应switch动作
-(void) switchAction:(id)sender
{
    BOOL isButtonOn = [m_balanceSwitch isOn];
    if (isButtonOn)
    {
        [m_DicClusterAndHost setObject:@"YES" forKey:@"Balance"];
    }
    else
    {
        [m_DicClusterAndHost setObject:@"NO" forKey:@"Balance"];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = ClusterViewTableIdentifier;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
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
                    label.text = @"Cluster ID: ";
                    [cell addSubview:label];

                    m_labelClusterID = [[UILabel alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - UIMARGIN_LEFT * 3 - 180.0f, (UITABLEVIEWCELL_HEIGHT - UITEXTFIELD_HEIGHT) / 2, 200, UITEXTFIELD_HEIGHT)];
                    m_labelClusterID.backgroundColor = [UIColor clearColor];
                    m_labelClusterID.textColor = [UIColor grayColor];
                    m_labelClusterID.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    m_labelClusterID.text = [m_DicClusterAndHost objectForKey:@"ID"];

                    [cell addSubview:m_labelClusterID];

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
                    m_textFieldName.text = [m_DicClusterAndHost objectForKey:@"Name"];

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
                    label.text = @"DefHostID: ";
                    [cell addSubview:label];

                    m_textFieldDefHost = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - UIMARGIN_LEFT * 3 - 180.0f, (UITABLEVIEWCELL_HEIGHT - UITEXTFIELD_HEIGHT) / 2, 200, UITEXTFIELD_HEIGHT)];
                    m_textFieldDefHost.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    m_textFieldDefHost.textAlignment = NSTextAlignmentLeft;
                    m_textFieldDefHost.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    m_textFieldDefHost.textColor = [UIColor grayColor];
                    m_textFieldDefHost.autocorrectionType = UITextAutocorrectionTypeNo;
                    m_textFieldDefHost.clearButtonMode = UITextFieldViewModeWhileEditing;
                    m_textFieldDefHost.delegate = self;
                    m_textFieldDefHost.text = [m_DicClusterAndHost objectForKey:@"DefHost"];

                    [cell addSubview:m_textFieldDefHost];

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
                    label.text = @"Balance: ";
                    [cell addSubview:label];

                    m_balanceSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - UIMARGIN_LEFT * 3 - 200.0f, (UITABLEVIEWCELL_HEIGHT - UITEXTFIELD_HEIGHT) / 2, 200, UITEXTFIELD_HEIGHT)];
                    if ([[m_DicClusterAndHost objectForKey:@"Balance"] isEqualToString:@"YES"])
                    {
                        [m_balanceSwitch setOn:YES];
                    }
                    else
                    {
                        [m_balanceSwitch setOn:NO];
                    }
                    [m_balanceSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    [cell addSubview:m_balanceSwitch];

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
                    cell.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:243.0/255.0 blue:238.0/255.0 alpha:1.0];

                    UILabel *bottomlabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, UITABLEVIEWCELL_SECTION_HEIGHT-1,cell.contentView.frame.size.width, 1)];
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
                    label.text = @"Host";
                    [cell addSubview:label];

                    m_addButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    m_addButton.frame = CGRectMake(cell.contentView.frame.size.width - UIMARGIN_LEFT * 3 - 200.0f+80.0f, (UITABLEVIEWCELL_HEIGHT - UITEXTFIELD_HEIGHT) / 2, 80, UITEXTFIELD_HEIGHT);
                    [m_addButton setTitle:@"添加" forState:UIControlStateNormal];
                    [m_addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [m_addButton addTarget:self action:@selector(addData) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:m_addButton];

                    m_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    m_deleteButton.frame = CGRectMake(cell.contentView.frame.size.width - UIMARGIN_LEFT * 3 - 60.0f, (UITABLEVIEWCELL_HEIGHT - UITEXTFIELD_HEIGHT) / 2, 80, UITEXTFIELD_HEIGHT);
                    [m_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
                    [m_deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [m_deleteButton addTarget:self action:@selector(deleteData) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:m_deleteButton];

                    UIView *tempView = [[UIView alloc] init];
                    tempView.backgroundColor = [UIColor whiteColor];
                    [cell setBackgroundView:tempView];

                    UILabel *bottomlabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, UITABLEVIEWCELL_HEIGHT-1,cell.contentView.frame.size.width, 1)];
                    bottomlabel.backgroundColor=cellseparatorlinecolor;
                    [cell addSubview:bottomlabel];
                    break;
                }
            default:
                {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(UIMARGIN_LEFT * 4, (UITABLEVIEWCELL_HEIGHT - UILABEL_HEIGHT) / 2, 80.0f,UILABEL_HEIGHT)];
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = [UIColor grayColor];
                    label.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                    //NSLog(@"----default,m_DicClusterAndHost:%@",m_DicClusterAndHost);
                    //NSLog(@"----[m_ArrClusterHost i:%d,%@",indexPath.row - 7 ,[m_ArrClusterHost objectAtIndex:indexPath.row - 7]);
                    label.text = [[m_ArrClusterHost objectAtIndex:indexPath.row - 7] objectForKey:@"ID"];
                    [cell addSubview:label];

                    UIView *tempView = [[UIView alloc] init];
                    tempView.backgroundColor = [UIColor whiteColor];
                    [cell setBackgroundView:tempView];
                    
                    UILabel *bottomlabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, UITABLEVIEWCELL_HEIGHT-1,cell.contentView.frame.size.width, 1)];
                    bottomlabel.backgroundColor=cellseparatorlinecolor;
                    [cell addSubview:bottomlabel];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
            }
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        case 5:
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([indexPath row] >= 7)
    {
        NSString* idCluster = [m_DicClusterAndHost objectForKey:@"ID"];
        hostView = [[TdxHostView alloc] init];
        hostView.m_DicHost = [[m_DicClusterAndHost objectForKey: idCluster] objectAtIndex:indexPath.row - 7];
        //NSLog(@"----ClusterView==didSelectRowAtIndexPath, m_DicHost:%@",hostView.m_DicHost);
        [hostView setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:hostView animated:YES];
    }
}

#pragma mark - TableView delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//提交编辑操作时会调用这个方法(删除，添加)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 删除操作
    if (editingState == UITableViewCellEditingStyleDelete) {
        // 1.删除数据
        [m_ArrClusterHost removeObjectAtIndex:indexPath.row-7];
        
        // 2.更新UITableView UI界面
        //[tableView reloadData];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //NSLog(@"-----commitEditStyle, m_DicClusterAndHost:%@",m_DicClusterAndHost);
        
        //若只剩下最后一个HOST ID，将其状态置反
        if(m_ArrClusterHost.count == 1)
        {
            BOOL isEditing = m_table.isEditing;
            // 开启\关闭编辑模式
            [m_table setEditing:!isEditing animated:YES];
        }
    }
    else if(editingState == UITableViewCellEditingStyleInsert)
    {
        
        //我们实现的是在所选行的位置插入一行，因此直接使用了参数indexPath
        NSArray *insertIndexPaths = [NSArray arrayWithObjects:indexPath,nil];
        [m_table insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
        [m_table reloadData];
    }
}

#pragma mark 决定tableview的编辑模式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= 7) {
        return editingState;
    }
    return UITableViewCellEditingStyleNone;
}

#pragma mark - 公共方法
// 删除数据
- (void)deleteData {
    
    if(m_ArrClusterHost.count == 1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请至少保留一个Host" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    editingState = UITableViewCellEditingStyleDelete;
    BOOL isEditing = m_table.isEditing;
    // 开启\关闭编辑模式
    [m_table setEditing:!isEditing animated:YES];
}

// 添加数据
- (void)addData
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入HostID" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    // 弹出UIAlertView
    [alert show];
}

#pragma mark - UIAlertView delegate
-(void) alertView : (UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"确定"])
    {
        m_newAddHostIDStr = [alertView textFieldAtIndex:0].text;//获得输入框
        //判断添加的HostID是唯一的，没有与之相同的ID
        for(int i = 0; i < m_ArrClusterHost.count; i++)
        {
            if ([m_newAddHostIDStr isEqual:[[m_ArrClusterHost objectAtIndex:i] objectForKey:@"ID"]])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"添加失败" message:@"不能添加已有ID" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alert show];
                
                return;
            }
        }

        //新建立一个Host
        m_newDicHost = [NSMutableDictionary dictionaryWithCapacity:6];
        [m_newDicHost setObject:@"" forKey:@"Addr"];
        [m_newDicHost setObject:@"" forKey:@"CN"];
        
        [m_newDicHost setObject:m_newAddHostIDStr forKey:@"ID"];
        [m_newDicHost setObject:@"" forKey:@"Name"];
        [m_newDicHost setObject:@"" forKey:@"Port"];
        [m_newDicHost setObject:@"100" forKey:@"WeightFactor"];
        [m_ArrClusterHost addObject:m_newDicHost];

        [m_table beginUpdates];
        NSArray *_tempIndexPathArr = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:rowNum inSection:0]];
        [m_table insertRowsAtIndexPaths:_tempIndexPathArr withRowAnimation:UITableViewRowAnimationNone];
        [m_table endUpdates];

        hostView = [[TdxHostView alloc] init];
        hostView.m_DicHost = [m_ArrClusterHost objectAtIndex:rowNum - 8];
        [hostView setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:hostView animated:YES];
    }
    else
    {
        return;
    }
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
    [m_table setContentOffset:CGPointMake(0, UITABLEVIEWCELL_SECTION_HEIGHT) animated:YES];
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
//
//  TdxTools.m
//  TdxTools
//
//
//  Created by xiawenxing on 15/5/4.
//  Copyright (c) 2015年 tdx.com.iPhone. All rights reserved.
//

#import "TdxTools.h"
#import "GDataXMLNode.h"
#import "TdxClusterView.h"
#import "TdxPickerView.h"
#import "UIViewPassValueDelegate.h"
#import "TdxMacroDefinition.h"

@interface TdxTools () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIViewPassValueDelegate>
{
    
    NSMutableArray* m_ArrCluster;
    NSMutableArray* m_ArrClusterHost;
    UIButton *m_leftButton;
    UITableView*    m_table;
    UITableViewCellEditingStyle editingState;
    
    UIButton *m_addButton;
    UIButton *m_deleteButton;
    
    NSMutableArray* m_usedClusterID;
    NSMutableArray* m_notUsedClusterID;
    
    NSString *m_addLabelText;
    NSMutableDictionary *m_newDicCluster;
    NSMutableArray *m_newArrayClusterHost;
    NSMutableDictionary *m_newDicClusterHost;
    
    TdxClusterView *clusterView;
}
@end

@implementation TdxTools

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self LoadTaAPIXml];
        m_usedClusterID = [[NSMutableArray alloc] init];
        m_notUsedClusterID = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)LoadTaAPIXml
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cPath = [paths objectAtIndex:0];
    //NSLog(@"-----cPath:%@",cPath);
    NSString * xmlfile = [[NSString alloc] initWithFormat:@"%@/%@", cPath, @"home/syscfg/taapi.xml"];
    
    NSString* fileText = [NSString stringWithContentsOfFile:xmlfile encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000) error:nil];
    fileText=[fileText stringByReplacingOccurrencesOfString:@"gb2312" withString:@"UTF-8"];
    fileText=[fileText stringByReplacingOccurrencesOfString:@"GB2312" withString:@"UTF-8"];
    
    NSError* error;
    GDataXMLDocument* document = [[GDataXMLDocument alloc] initWithXMLString:fileText options:0 error:&error];
    GDataXMLElement *rootNode = [document rootElement];
    
    NSArray* nodelist = [rootNode nodesForXPath:@"/Optional/TAEngine/ClusterGroup" error:&error];
    m_ArrCluster = [[NSMutableArray alloc] init];
    
    for(GDataXMLNode* node in nodelist)
    {
        NSArray* nodelist1 = [node nodesForXPath:@"./Cluster" error:&error];
        if(nodelist1 && [nodelist1 count])
        {
            for(GDataXMLNode *node1 in nodelist1)
            {
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                m_ArrClusterHost = [[NSMutableArray alloc] init];
                NSArray* nodelist2 = [node1 nodesForXPath:@"./Host" error:&error];
                for (GDataXMLNode *node2 in nodelist2)
                {
                    NSMutableDictionary* dict2 = [[NSMutableDictionary alloc] init];
                    
                    NSString* idStr=[NSString stringWithFormat:@"%@",[node2 GetAttributeStringValue:@"ID"]];
                    [dict2 setObject:idStr forKey:@"ID"];
                    
                    NSString* Name=[NSString stringWithFormat:@"%@",[node2 GetAttributeStringValue:@"Name"]];
                    [dict2 setObject:Name forKey:@"Name"];
                    
                    NSString* Addr = [NSString stringWithFormat:@"%@",[node2 GetAttributeStringValue:@"Addr"]];
                    [dict2 setObject:Addr forKey:@"Addr"];
                    
                    NSString* Port=[NSString stringWithFormat:@"%@",[node2 GetAttributeStringValue:@"Port"]];
                    [dict2 setObject:Port forKey:@"Port"];
                    
                    NSString* CN = [NSString stringWithFormat:@"%@",[node2 GetAttributeStringValue:@"CN"]];
                    [dict2 setObject:CN forKey:@"CN"];
                    
                    NSString* WeightFactor = [NSString stringWithFormat:@"%@",[node2 GetAttributeStringValue:@"WeightFactor"]];
                    [dict2 setObject:WeightFactor forKey:@"WeightFactor"];
                    
                    [m_ArrClusterHost addObject:dict2];
                    
                }
                
                NSString* idStr=[NSString stringWithFormat:@"%@",[node1 GetAttributeStringValue:@"ID"]];
                [dict setObject:idStr forKey:@"ID"];
                
                NSString* Name=[NSString stringWithFormat:@"%@",[node1 GetAttributeStringValue:@"Name"]];
                [dict setObject:Name forKey:@"Name"];
                
                NSString* DefHost=[NSString stringWithFormat:@"%@",[node1 GetAttributeStringValue:@"DefHost"]];
                [dict setObject:DefHost forKey:@"DefHost"];
                
                NSString* Balance=[NSString stringWithFormat:@"%@",[node1 GetAttributeStringValue:@"Balance"]];
                [dict setObject:Balance forKey:@"Balance"];
                
                [dict setObject:m_ArrClusterHost forKey:idStr];
                
                [m_ArrCluster addObject:dict];
            }
        }
    }
    //NSLog(@"----LoadGuiTaiXml, m_ArrCluster:%@",m_ArrCluster);
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
    self.navigationItem.title = @"服务器参数设置";
    
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
    
    //NSLog(@"----TdxTaAPI,viewLoad,m_ArrCluster:%@",m_ArrCluster);
}

#pragma mark - deal with XML
-(void) assembleClusterAndHostXML:(GDataXMLElement *)ClusterGroupElement
{
    for(int i = 0; i < [m_ArrCluster count]; i++)
    {
        NSMutableDictionary *tmpDic = [m_ArrCluster objectAtIndex:i];
        NSString *ID = [tmpDic objectForKey:@"ID"];
        //Cluster
        GDataXMLElement *ClusterElement = [GDataXMLNode elementWithName:@"Cluster" stringValue:nil];
        [ClusterElement addChild:[GDataXMLNode attributeWithName:@"ID" stringValue:ID]];
        [ClusterElement addChild:[GDataXMLNode attributeWithName:@"Name" stringValue:[tmpDic objectForKey:@"Name"]]];
        [ClusterElement addChild:[GDataXMLNode attributeWithName:@"DefHost" stringValue:[tmpDic objectForKey:@"DefHost"]]];
        [ClusterElement addChild:[GDataXMLNode attributeWithName:@"Balance" stringValue:[tmpDic objectForKey:@"Balance"]]];
        
        NSMutableArray* arrHost = [tmpDic objectForKey:ID];
        for (int j = 0; j < arrHost.count; j++)
        {
            NSMutableDictionary *tmpHostDic = [[tmpDic objectForKey:ID] objectAtIndex:j];
            
            GDataXMLElement *HostElement = [GDataXMLNode elementWithName:@"Host" stringValue:nil];
            [HostElement addChild:[GDataXMLNode attributeWithName:@"ID" stringValue:[tmpHostDic objectForKey:@"ID"]]];
            [HostElement addChild:[GDataXMLNode attributeWithName:@"Name" stringValue:[tmpHostDic objectForKey:@"Name"]]];
            [HostElement addChild:[GDataXMLNode attributeWithName:@"Addr" stringValue:[tmpHostDic objectForKey:@"Addr"]]];
            [HostElement addChild:[GDataXMLNode attributeWithName:@"Port" stringValue:[tmpHostDic objectForKey:@"Port"]]];
            [HostElement addChild:[GDataXMLNode attributeWithName:@"WeightFactor" stringValue:[tmpHostDic objectForKey:@"WeightFactor"]]];
            [HostElement addChild:[GDataXMLNode attributeWithName:@"CN" stringValue:[tmpHostDic objectForKey:@"CN"]]];
            [ClusterElement addChild:HostElement];
        }
        
        [ClusterGroupElement addChild:ClusterElement];
    }
}

//在返回到上一级菜单前 将参数写到XML文件中
-(void) writeDataToXML
{
    //重写XML文件
    GDataXMLElement *optionalElement = [GDataXMLNode elementWithName:@"Optional"];
    GDataXMLElement *TAEngineElement = [GDataXMLNode elementWithName:@"TAEngine"];
    
    //CoreThread
    GDataXMLElement *CoreThreadElement = [GDataXMLNode elementWithName:@"CoreThread" stringValue:nil];
    [CoreThreadElement addChild:[GDataXMLNode attributeWithName:@"ThreadNum" stringValue:@"2"] ];
    [TAEngineElement addChild:CoreThreadElement];
    
    //CoreTimeout
    GDataXMLElement *CoreTimeoutElement = [GDataXMLNode elementWithName:@"CoreThread" stringValue:nil];
    [CoreTimeoutElement addChild:[GDataXMLNode attributeWithName:@"JobTimeout" stringValue:@"150000"] ];
    [TAEngineElement addChild:CoreTimeoutElement];
    
    //CoreMemory
    GDataXMLElement *CoreMemoryElement = [GDataXMLNode elementWithName:@"CoreMemory" stringValue:nil];
    [CoreMemoryElement addChild:[GDataXMLNode attributeWithName:@"ReqBufSize" stringValue:@"4096"]];
    [CoreMemoryElement addChild:[GDataXMLNode attributeWithName:@"AnsBufSize" stringValue:@"65535"]];
    [TAEngineElement addChild:CoreTimeoutElement];
    
    //Memory
    GDataXMLElement *MemoryElement = [GDataXMLNode elementWithName:@"Memory" stringValue:nil];
    [MemoryElement addChild:[GDataXMLNode attributeWithName:@"MaxClient" stringValue:@"-1"]];
    [MemoryElement addChild:[GDataXMLNode attributeWithName:@"MaxPeer" stringValue:@"-1"]];
    [MemoryElement addChild:[GDataXMLNode attributeWithName:@"Pool" stringValue:@"YES"]];
    [TAEngineElement addChild:MemoryElement];
    
    //TCP
    GDataXMLElement *TCPElement = [GDataXMLNode elementWithName:@"TCP" stringValue:nil];
    [TCPElement addChild:[GDataXMLNode attributeWithName:@"Linger" stringValue:@"NO"]];
    [TCPElement addChild:[GDataXMLNode attributeWithName:@"ReuseAddr" stringValue:@"NO"]];
    [TCPElement addChild:[GDataXMLNode attributeWithName:@"Nodelay" stringValue:@"YES"]];
    [TAEngineElement addChild:TCPElement];
    
    //Packet
    GDataXMLElement *PacketElement = [GDataXMLNode elementWithName:@"Packet" stringValue:nil];
    [PacketElement addChild:[GDataXMLNode attributeWithName:@"ReqSegmentSize" stringValue:@"4096"]];
    [PacketElement addChild:[GDataXMLNode attributeWithName:@"AckSegmentSize" stringValue:@"-1"]];
    [TAEngineElement addChild:PacketElement];
    
    //Proxy
    GDataXMLElement *ProxyElement = [GDataXMLNode elementWithName:@"Proxy" stringValue:nil];
    [ProxyElement addChild:[GDataXMLNode attributeWithName:@"Type" stringValue:@"0"]];
    [ProxyElement addChild:[GDataXMLNode attributeWithName:@"Server" stringValue:@""]];
    [ProxyElement addChild:[GDataXMLNode attributeWithName:@"Port" stringValue:@""]];
    [ProxyElement addChild:[GDataXMLNode attributeWithName:@"Authorization" stringValue:@"NO"]];
    [ProxyElement addChild:[GDataXMLNode attributeWithName:@"Username" stringValue:@""]];
    [ProxyElement addChild:[GDataXMLNode attributeWithName:@"Password" stringValue:@""]];
    [ProxyElement addChild:[GDataXMLNode attributeWithName:@"Domain" stringValue:@""]];
    [ProxyElement addChild:[GDataXMLNode attributeWithName:@"DNS" stringValue:@"YES"]];
    [ProxyElement addChild:[GDataXMLNode attributeWithName:@"Exclude" stringValue:@""]];
    [TAEngineElement addChild:ProxyElement];
    
    //TdxProxy
    GDataXMLElement *TdxProxyElement = [GDataXMLNode elementWithName:@"TdxProxy" stringValue:nil];
    [TdxProxyElement addChild:[GDataXMLNode attributeWithName:@"Type" stringValue:@"0"]];
    [TdxProxyElement addChild:[GDataXMLNode attributeWithName:@"Server" stringValue:@""]];
    [TdxProxyElement addChild:[GDataXMLNode attributeWithName:@"Port" stringValue:@""]];
    [TAEngineElement addChild:TdxProxyElement];
    
    //Compres
    GDataXMLElement *CompressElement = [GDataXMLNode elementWithName:@"Compres" stringValue:nil];
    [CompressElement addChild:[GDataXMLNode attributeWithName:@"Mode" stringValue:@"0"]];
    [CompressElement addChild:[GDataXMLNode attributeWithName:@"MinSize" stringValue:@"1024"]];
    [TAEngineElement addChild:CompressElement];
    
    //Timeout
    GDataXMLElement *TimeoutsElement = [GDataXMLNode elementWithName:@"Compres" stringValue:nil];
    [TimeoutsElement addChild:[GDataXMLNode attributeWithName:@"Create" stringValue:@"10000"]];
    [TimeoutsElement addChild:[GDataXMLNode attributeWithName:@"Transaction" stringValue:@"10000"]];
    [TAEngineElement addChild:TimeoutsElement];
    
    //HeartBeat
    GDataXMLElement *HeartBeatElement = [GDataXMLNode elementWithName:@"HeartBeat" stringValue:nil];
    [HeartBeatElement addChild:[GDataXMLNode attributeWithName:@"TimeSpan" stringValue:@"0"]];
    [HeartBeatElement addChild:[GDataXMLNode attributeWithName:@"InetDebug" stringValue:@""]];
    [HeartBeatElement addChild:[GDataXMLNode attributeWithName:@"OnIdle" stringValue:@""]];
    [HeartBeatElement addChild:[GDataXMLNode attributeWithName:@"JustNoQueue" stringValue:@"NO"]];
    [TAEngineElement addChild:HeartBeatElement];
    
    //CodePage
    GDataXMLElement *CodePageElement = [GDataXMLNode elementWithName:@"CodePage" stringValue:nil];
    [CodePageElement addChild:[GDataXMLNode attributeWithName:@"Neutral" stringValue:@"936"]];
    [CodePageElement addChild:[GDataXMLNode attributeWithName:@"Terminal" stringValue:@"936"]];
    [TAEngineElement addChild:CodePageElement];
    
    //Balance
    GDataXMLElement *BalanceElement = [GDataXMLNode elementWithName:@"Balance" stringValue:nil];
    [BalanceElement addChild:[GDataXMLNode attributeWithName:@"UseMT" stringValue:@"NO"]];
    [BalanceElement addChild:[GDataXMLNode attributeWithName:@"JustNet" stringValue:@"NO"]];
    [BalanceElement addChild:[GDataXMLNode attributeWithName:@"TimeLimit" stringValue:@"8000"]];
    [BalanceElement addChild:[GDataXMLNode attributeWithName:@"ReachLimit" stringValue:@"0"]];
    [BalanceElement addChild:[GDataXMLNode attributeWithName:@"Less" stringValue:@"NO"]];
    [BalanceElement addChild:[GDataXMLNode attributeWithName:@"ByEPID" stringValue:@"NO"]];
    [TAEngineElement addChild:BalanceElement];
    
    //COM
    GDataXMLElement *COMElement = [GDataXMLNode elementWithName:@"COM" stringValue:nil];
    [COMElement addChild:[GDataXMLNode attributeWithName:@"DispatchThread" stringValue:@"0"]];
    [TAEngineElement addChild:COMElement];
    
    //Channel
    GDataXMLElement *ChannelElement = [GDataXMLNode elementWithName:@"Channel" stringValue:nil];
    [ChannelElement addChild:[GDataXMLNode attributeWithName:@"CheckConnect" stringValue:@"3"]];
    [TAEngineElement addChild:ChannelElement];
    
    //ClusterGroup
    GDataXMLElement *ClusterGroupElement = [GDataXMLNode elementWithName:@"ClusterGroup" stringValue:nil];
    [self assembleClusterAndHostXML:ClusterGroupElement];
    [TAEngineElement addChild:ClusterGroupElement];
    
    //CertRoot
    GDataXMLElement *CertRootElement = [GDataXMLNode elementWithName:@"CertRoot" stringValue:nil];
    [TAEngineElement addChild:CertRootElement];
    
    //LocalKey
    GDataXMLElement *LocalKeyElement = [GDataXMLNode elementWithName:@"LocalKey" stringValue:nil];
    [LocalKeyElement addChild:[GDataXMLNode attributeWithName:@"Path" stringValue:@"Tendency\\TAAPI\\KEY"]];
    [TAEngineElement addChild:LocalKeyElement];
    
    //添加根目录
    [optionalElement addChild:TAEngineElement];
    GDataXMLDocument *newDocument = [[GDataXMLDocument alloc] initWithRootElement:optionalElement];
    [newDocument setCharacterEncoding:@"GB2312"];
    NSData *xmlData = newDocument.XMLData;
    
    NSArray* newPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* Path = [newPaths objectAtIndex:0];
    NSString * xmlfile = [[NSString alloc] initWithFormat:@"%@/%@", Path, @"home/syscfg/taapi.xml"];
    
    xmlfile=[xmlfile stringByReplacingOccurrencesOfString:@"gb2312" withString:@"UTF-8"];
    //   xmlfile=[fileText stringByReplacingOccurrencesOfString:@"GB2312" withString:@"UTF-8"];
    
    [xmlData writeToFile:xmlfile atomically:YES];
}

- (IBAction)buttonBack:(id)sender
{
    //NSLog(@"----buttonBack--TdxTaAPI, m_ArrCluster:%@",m_ArrCluster);
    [self writeDataToXML];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - system call function
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@"----numberOfRowsInSection,m_ArrCluster:%lu",m_ArrCluster.count+2);
    return m_ArrCluster.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = ClusterGroupTableIdentifier;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIColor* cellseparatorlinecolor=[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        switch(indexPath.row)
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
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(UIMARGIN_LEFT * 2, (UITABLEVIEWCELL_HEIGHT - UILABEL_HEIGHT) / 2, 120.0f,UILABEL_HEIGHT)];
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor grayColor];
                label.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                label.text = @"Cluster Group";
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
                //NSLog(@"---default,indexPath.row:%ld",(long)indexPath.row);
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(UIMARGIN_LEFT * 4, (UITABLEVIEWCELL_HEIGHT - UILABEL_HEIGHT) / 2, 80.0f,UILABEL_HEIGHT)];
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor grayColor];
                label.font = [UIFont systemFontOfSize:FONT_SIZE_NORMAL];
                label.text = [[m_ArrCluster objectAtIndex:indexPath.row - 2] objectForKey:@"ID"];
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
    return indexPath;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= 2)
    {
        clusterView = [[TdxClusterView alloc] init];
        clusterView.m_DicClusterAndHost = [m_ArrCluster objectAtIndex:[indexPath row]-2 ];
        [clusterView setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:clusterView animated:YES];
    }
}

#pragma mark - UIViewPassValue delegate
- (void)passValue:(NSString *)value
{
    //创建一个新的cluster对象
    m_newDicCluster = [NSMutableDictionary dictionaryWithCapacity:5];
    NSString *hostID = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",value,@"1"]];
    [m_newDicCluster setObject:value forKey:@"ID"];
    [m_newDicCluster setObject:@"" forKey:@"Name"];
    [m_newDicCluster setObject:hostID forKey:@"DefHost"];
    [m_newDicCluster setObject:@"" forKey:@"Balance"];
    
    m_newArrayClusterHost = [[NSMutableArray alloc] init];
    m_newDicClusterHost = [NSMutableDictionary dictionaryWithCapacity:6];
    [m_newDicClusterHost setObject:@"" forKey:@"Addr"];
    [m_newDicClusterHost setObject:@"" forKey:@"CN"];
    
    [m_newDicClusterHost setObject:hostID forKey:@"ID"];
    [m_newDicClusterHost setObject:@"" forKey:@"Name"];
    [m_newDicClusterHost setObject:@"" forKey:@"Port"];
    [m_newDicClusterHost setObject:@"100" forKey:@"WeightFactor"];
    [m_newArrayClusterHost addObject:m_newDicClusterHost];
    
    [m_newDicCluster setObject:m_newArrayClusterHost forKey:value];
    
    int row = m_ArrCluster.count+2;
    
    [m_table beginUpdates];
    [m_ArrCluster addObject:m_newDicCluster];
        NSArray *_tempIndexPathArr = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]];
    [m_table insertRowsAtIndexPaths:_tempIndexPathArr withRowAnimation:UITableViewRowAnimationNone];
    [m_table endUpdates];
}

#pragma mark - TableView delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void) addCluster
{
    NSMutableArray* m_allClusterID = [NSMutableArray arrayWithObjects:@"100",@"101",@"102",@"103",@"200",@"201",@"202",nil];
    for (int i = 0; i < [m_ArrCluster count]; i++) {
        NSString* usedID = [[m_ArrCluster objectAtIndex:i] objectForKey:@"ID"];
        [m_allClusterID removeObject:usedID];
    }
    m_notUsedClusterID = m_allClusterID;
    
    if ([m_notUsedClusterID count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"ID已全部被使用。" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    TdxPickerView *picker = [[TdxPickerView alloc] init];
    picker.pickerData = m_notUsedClusterID;
    picker.delegate = self;
    [picker setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:picker animated:YES];
}

//提交编辑操作时会调用这个方法(删除，添加)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 删除操作
    if (editingState == UITableViewCellEditingStyleDelete) {
        // 1.删除数据
        [m_ArrCluster removeObjectAtIndex:indexPath.row-2];
        
        // 2.更新UITableView UI界面
        // [tableView reloadData];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //NSLog(@"----commitEditStyle, m_ArrCluster:%@",m_ArrCluster);
    }
}

#pragma mark 决定tableview的编辑模式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= 2)
    {
        return editingState;
    }
    return UITableViewCellEditingStyleNone;
}

#pragma mark - 公共方法
// 删除数据
- (void)deleteData
{
    editingState = UITableViewCellEditingStyleDelete;
    
    // 开始编辑模式
    // self.tableView.editing = YES;
    // [self.tableView setEditing:YES];
    
    BOOL isEditing = m_table.isEditing;
    // 开启\关闭编辑模式
    [m_table setEditing:!isEditing animated:YES];
}

// 添加数据
- (void)addData
{
    [self addCluster];
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

@end


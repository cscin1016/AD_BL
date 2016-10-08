//
//  LampsViewController.m
//  RESideMenuExample
//
//  Created by 3013 on 14-5-28.
//  Copyright (c) 2014年 Roman Efimov. All rights reserved.
//

#import "LampsViewController.h"
#import "SubCollectionsCell2.h"
#import "GroupViewController.h"
#import "PopupView.h"




#define TRANSFER_SERVICE_UUID           @"FFF0"
#define TRANSFER_CHARACTERISTIC_UUID_1    @"FFF1"
#define TRANSFER_CHARACTERISTIC_UUID_4    @"FFF4"
#define TRANSFER_CHARACTERISTIC_UUID_5    @"FFF5"
#define rowcellCount 2

@interface LampsViewController ()
{
    BOOL isLightOn;//当前灯的状态是否为开，用于显示按钮的背景图片
    BOOL canSendMes;//是否能发送开关灯指令
    
    UIBarButtonItem *GroupAddButton;//选择group时的右侧导航按钮
    UIBarButtonItem *AllButton;//选择All时的右侧导航按钮
    
    NSMutableArray *dataArray;//用于在all和group切换时保存所有蓝牙信息
    NSMutableArray *GroupArray;//用于在all和group切换时保存group信息
    NSMutableArray *lightConnectGroupArray;//灯和组的对应关系
    
    UISegmentedControl *segmentedContol;//分段控件
    
    
    NSUserDefaults *userDefaults;
    
    PopupView  *popUpView;
}

@property (strong,nonatomic) UITableView * tableViewPeripheral;//表视图

@property (strong,nonatomic) NSMutableArray *allLightArray;//用于实时获取搜索到得数据
@property (strong,nonatomic) NSMutableArray *peripheralArray;//界面显示的数据源

@property (strong,nonatomic) CBCentralManager * cbCentralMgr;//蓝牙中心管理器
@end

@implementation LampsViewController

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
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    dataArray=[[NSMutableArray alloc] init];//用于在all和group切换时保存所有蓝牙信息
    GroupArray=[[NSMutableArray alloc]init];//用于在all和group切换时保存group信息
    self.peripheralArray = [NSMutableArray array];//界面显示的数据源
    self.cbCentralMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];//蓝牙操作中心
    
    //获取所有对应关系
    lightConnectGroupArray=[[NSMutableArray alloc]initWithArray:[userDefaults objectForKey:@"lightConnectGroup"]];
    
    //建一个方法，将lightConnectGroupArray对应到GroupArray
    
    popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 240, 0, 0)];
    popUpView.ParentView = self.view;
    
    self.title=NSLocalizedStringFromTable(@"LampsView_TITLE", @"InfoPlist", nil);
    
    //背景图片
    UIImageView *imaggeview=[[UIImageView alloc]initWithFrame:CGRectMake(0,64-(ADJUSTMENT), 320, [[UIScreen mainScreen] bounds].size.height)];
    [imaggeview setImage:[UIImage imageNamed:@"app_bg"]];
    [self.view addSubview:imaggeview];
    
    
    //初始化导航栏上的按钮
    if (IS_IOS_7) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_Left.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(BackAction)];
        self.navigationItem.leftBarButtonItem.tintColor=[UIColor whiteColor];
        
        AllButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStylePlain target:self action:@selector(seachAction)];
        AllButton.tintColor=[UIColor whiteColor];
        
        self.navigationItem.rightBarButtonItem = AllButton;
        
        GroupAddButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(groupAddAction)];
        GroupAddButton.tintColor=[UIColor whiteColor];
        
    }else{
        UIButton *btnLeft=[UIButton buttonWithType:UIButtonTypeCustom];
        btnLeft.frame=CGRectMake(0, 0, 24, 24);
        [btnLeft setBackgroundImage:[UIImage imageNamed:@"nav_Left.png"] forState:UIControlStateNormal];
        [btnLeft addTarget:self action:@selector(BackAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnLeft];
        
        UIButton *btnRight=[UIButton buttonWithType:UIButtonTypeCustom];
        btnRight.frame=CGRectMake(0, 0, 24, 24);
        [btnRight setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
        [btnRight addTarget:self action:@selector(seachAction) forControlEvents:UIControlEventTouchUpInside];
        AllButton=[[UIBarButtonItem alloc]initWithCustomView:btnRight];
        self.navigationItem.rightBarButtonItem=AllButton;
        
        
        UIButton *btnGroup=[UIButton buttonWithType:UIButtonTypeCustom];
        btnGroup.frame=CGRectMake(0, 0, 24, 24);
        [btnGroup setBackgroundImage:[UIImage imageNamed:@"add4"] forState:UIControlStateNormal];
        [btnGroup addTarget:self action:@selector(groupAddAction) forControlEvents:UIControlEventTouchUpInside];
        GroupAddButton = [[UIBarButtonItem alloc] initWithCustomView:btnGroup];
        GroupAddButton.tintColor=[UIColor clearColor];
        
    }
    
    
    //初始化tableview
    self.tableViewPeripheral=[[UITableView alloc]initWithFrame:CGRectMake(0,64-(ADJUSTMENT), 320, [[UIScreen mainScreen] bounds].size.height-104+(ADJUSTMENT)) style:UITableViewStylePlain];
    self.tableViewPeripheral.dataSource=self;
    self.tableViewPeripheral.delegate=self;
    self.tableViewPeripheral.backgroundColor=[UIColor clearColor];
    self.tableViewPeripheral.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableViewPeripheral];
    
    
    //设置分段控件
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:NSLocalizedStringFromTable(@"LampsView_ALlLight", @"InfoPlist", nil),NSLocalizedStringFromTable(@"LampsView_Group", @"InfoPlist", nil),nil];
    segmentedContol = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    segmentedContol.frame =CGRectMake(0, [[UIScreen mainScreen]bounds].size.height-40-(ADJUSTMENT), [[UIScreen mainScreen]bounds].size.width, 40);
    segmentedContol.selectedSegmentIndex=0;
    segmentedContol.segmentedControlStyle=UISegmentedControlStyleBar;
    [segmentedContol addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedContol];
    
    //执行搜索
    [self seachAction];
    
    //注册消息通知，接收分组返回的数据
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(ADDGroup:) name:@"ADDGroupOpration" object:nil];

}

//处理分段控件事件
-(void)segmentAction:(UISegmentedControl *)Seg
{
    NSInteger Index = Seg.selectedSegmentIndex;
    switch (Index)
    {
        case 0:
            [self allButtonAction];
            break;
        case 1:
            [self groupButtonAction];
            break;
        default:
            break;
    }
}
//所有灯泡界面
-(void)allButtonAction{
    self.navigationItem.rightBarButtonItem=AllButton;
    
    self.peripheralArray=dataArray;
    [self.tableViewPeripheral reloadData];
    
}
//所有分组界面
-(void)groupButtonAction{
    self.navigationItem.rightBarButtonItem = GroupAddButton;
    
    self.peripheralArray=[[NSMutableArray alloc]initWithArray:GroupArray];//显示分组信息
    [self getGroupFromAllConnection];
    [self.tableViewPeripheral reloadData];
}

//响应临时分组方法，响应创建分组
-(void)ADDGroup:(NSNotification*) notification
{
    NSDictionary *getDic=[notification object];
    NSMutableArray *arrayTem=[NSMutableArray array];//group页面打勾的数据
    [getDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        if ([obj intValue])
        {
            [arrayTem addObject:key];
        }
    }];
    //groupDic保存已连接的数组，seachedArray被搜索到的数组，allGroupNumber组内总成员数组
    NSMutableDictionary *groupMember=[[NSMutableDictionary alloc]initWithObjectsAndKeys:[self getCurrentTime],@"GroupTime",@"100",@"liangdu",@"group",@"groupName",arrayTem,@"groupDic",dataArray,@"DataArray",arrayTem,@"seachedArray",arrayTem,@"allGroupNumber",@"0",@"type",nil];
    NSLog(@"dataArray:%@,arrayTem:%@",dataArray,arrayTem);
    [GroupArray addObject:groupMember];//将数据加入到组数组
    self.peripheralArray=GroupArray;//将组数据重新赋值給数据显示数组
    [self.tableViewPeripheral reloadData];//刷新表视图
}

//增加组
-(void)groupAddAction{
    GroupViewController *groupView=[[GroupViewController alloc]init];
    groupView.AllDataArray=dataArray;
    groupView.cbCentralMgr=self.cbCentralMgr;
    [self.navigationController pushViewController:groupView animated:YES];
}

-(void)seachAction{
    //用于在图片模式中显示灯的个数
    [userDefaults setInteger:0 forKey:@"numberOfLight"];
    
    //将当前所有连接的蓝牙断开重新搜索
    for (int i=0; i<[dataArray count]; i++) {
        CBPeripheral * peripheral=[dataArray objectAtIndex:i];
        if (peripheral.state!=0) {
            [self.cbCentralMgr cancelPeripheralConnection:peripheral];
        }
    }
    self.cbCentralMgr.delegate=self;
    [self.cbCentralMgr stopScan];
    
    [self.peripheralArray removeAllObjects];
    [dataArray removeAllObjects];
    [self.tableViewPeripheral reloadData];
    
    
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [self.cbCentralMgr scanForPeripheralsWithServices:nil options:dic];
    
}
-(void)BackAction{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.peripheralArray.count-1)/rowcellCount+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"Cell1";
    SubCollectionsCell2 *cell =(SubCollectionsCell2 *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    if (cell == nil)
    {
        cell = [[SubCollectionsCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
        cell.backgroundColor=[UIColor clearColor];
    }
    NSUInteger row=[indexPath row];
    for (NSInteger i = 0; i < rowcellCount; i++)
    {
        //奇数，cell2需要刷新数据，需要设置隐藏
        if (row*rowcellCount+i>self.peripheralArray.count-1)
        {
            cell.cellView2.hidden=YES;
            break;
        }
        //如果是ALL模式下所有灯泡的操作，判断是CBPeripheral对象
        if ([[self.peripheralArray objectAtIndex:row*rowcellCount + i] isKindOfClass:[CBPeripheral class]]) {
            //获取单个灯泡的蓝牙对象
            CBPeripheral * peripheral=[self.peripheralArray objectAtIndex:row*rowcellCount + i];
            //单个灯泡第一个cell
            if (i==0)
            {
                if (peripheral.state==2)
                {
                    [cell.cellView1.niandaiLabel setText:@"100"];
                    [cell.cellView1.nameLabel setTextColor:[UIColor whiteColor]];
                    [cell.cellView1.contentLabel setTextColor:[UIColor whiteColor]];
                    [cell.cellView1.iconImageView setImage:[UIImage imageNamed:@"light_pl_white"]];
                }else{
                    [cell.cellView1.niandaiLabel setText:@"0"];
                    [cell.cellView1.nameLabel setTextColor:[UIColor grayColor]];
                    [cell.cellView1.contentLabel setTextColor:[UIColor grayColor]];
                    [cell.cellView1.iconImageView setImage:[UIImage imageNamed:@"light_pl"]];
                }
                [cell.cellView1.titleLabel setText:@"%"];
                if([peripheral.name length]<=4){
                    [cell.cellView1.nameLabel setText:NSLocalizedStringFromTable(@"LampsView_NOName", @"InfoPlist", nil)];
                }else{
                    [cell.cellView1.nameLabel setText:[peripheral.name substringFromIndex:4]];
                }
                
                [cell.cellView1.contentLabel setText:[self seachLightConnectGroup:[peripheral.identifier UUIDString]]];
                cell.cellView1.tag=8000+row*rowcellCount + i;
                
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellviewTaped:)];
                [ cell.cellView1 addGestureRecognizer:tapRecognizer];
                
                UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
                longPress.minimumPressDuration=2;
                [cell.cellView1 addGestureRecognizer:longPress];
            }
            //单个灯泡第二个cell
            else
            {
                cell.cellView2.hidden=NO;
                if (peripheral.state==2)
                {
                    [cell.cellView2.iconImageView setImage:[UIImage imageNamed:@"light_pl_white"]];
                    [cell.cellView2.niandaiLabel setText:@"100"];
                    [cell.cellView2.contentLabel setTextColor:[UIColor whiteColor]];
                    [cell.cellView2.nameLabel setTextColor:[UIColor whiteColor]];
                }else{
                    [cell.cellView2.iconImageView setImage:[UIImage imageNamed:@"light_pl"]];
                    [cell.cellView2.niandaiLabel setText:@"0"];
                    [cell.cellView2.contentLabel setTextColor:[UIColor grayColor]];
                    [cell.cellView2.nameLabel setTextColor:[UIColor grayColor]];
                }
                [cell.cellView2.titleLabel setText:@"%"];
                if([peripheral.name length]<=4){
                    [cell.cellView2.nameLabel setText:NSLocalizedStringFromTable(@"LampsView_NOName", @"InfoPlist", nil)];
                }else{
                    [cell.cellView2.nameLabel setText:[peripheral.name substringFromIndex:4]];
                }
                [cell.cellView2.contentLabel setText:[self seachLightConnectGroup:[peripheral.identifier UUIDString]]];
                
                cell.cellView2.tag=8000+row*rowcellCount+i;
                
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellviewTaped:)];
                [ cell.cellView2 addGestureRecognizer:tapRecognizer];
                UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
                longPress.minimumPressDuration=2;
                [cell.cellView2 addGestureRecognizer:longPress];
            }
        }
        //group则使用以下单元格绘制
        else
        {
            //group模式下第一个cell
            if (i==0)
            {
                NSDictionary *groupDicData=[self.peripheralArray objectAtIndex:row*rowcellCount + i];
                [cell.cellView1.iconImageView setImage:[UIImage imageNamed:@"light_pl"]];
                
                [cell.cellView1.niandaiLabel setText:@"0"];
                [cell.cellView1.nameLabel setTextColor:[UIColor whiteColor]];
                [cell.cellView1.contentLabel setTextColor:[UIColor whiteColor]];
                [cell.cellView1.titleLabel setText:@"%"];
                
                //groupDic保存已连接的数组，seachedArray被搜索到的数组，allGroupNumber组内总成员数组
                if ([[groupDicData objectForKey:@"type"] intValue]) {
                    int seachedArrayNumber=0;
                    int groupDicNumber=0;
                    if ([groupDicData objectForKey:@"seachedArray"]!=nil) {
                        seachedArrayNumber=(int)[[groupDicData objectForKey:@"seachedArray"] count];
                    }
                    if ([groupDicData objectForKey:@"groupDic"]!=nil) {
                        groupDicNumber=(int)[[groupDicData objectForKey:@"groupDic"] count];
                    }
                    [cell.cellView1.contentLabel setText:[NSString stringWithFormat:@"%@%d%@,%@%d,%@%d",NSLocalizedStringFromTable(@"LampsView_GroupOne", @"InfoPlist", nil),(int)[[groupDicData objectForKey:@"allGroupNumber"] count],NSLocalizedStringFromTable(@"LampsView_GroupTwo", @"InfoPlist", nil),NSLocalizedStringFromTable(@"LampsView_GroupThree", @"InfoPlist", nil),seachedArrayNumber,NSLocalizedStringFromTable(@"LampsView_GroupFour", @"InfoPlist", nil),groupDicNumber]];
                    [cell.cellView1.nameLabel setText:[groupDicData objectForKey:@"groupName"]];
                }else{
                    [cell.cellView1.contentLabel setText:[NSString stringWithFormat:@"%@%d%@",NSLocalizedStringFromTable(@"LampsView_GroupOne", @"InfoPlist", nil),(int)[[groupDicData objectForKey:@"groupDic"] count],NSLocalizedStringFromTable(@"LampsView_GroupTwo", @"InfoPlist", nil)]];
                    [cell.cellView1.nameLabel setText:[groupDicData objectForKey:@"GroupTime"]];
                }
                
                cell.cellView1.tag=1000+row*rowcellCount + i;
                
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellviewTaped:)];
                [ cell.cellView1 addGestureRecognizer:tapRecognizer];
            }
            //group模式下第二个cell
            else
            {
                cell.cellView2.hidden=NO;
                NSDictionary *groupDicData=[self.peripheralArray objectAtIndex:row*rowcellCount + i];
                [cell.cellView2.iconImageView setImage:[UIImage imageNamed:@"light_pl"]];
                
                [cell.cellView2.niandaiLabel setText:@"0"];
                [cell.cellView2.contentLabel setTextColor:[UIColor whiteColor]];
                [cell.cellView2.nameLabel setTextColor:[UIColor whiteColor]];
                [cell.cellView2.titleLabel setText:@"%"];
                
                //groupDic保存已连接的数组，seachedArray被搜索到的数组，allGroupNumber组内总成员数组
                if ([[groupDicData objectForKey:@"type"] intValue]) {
                    int seachedArrayNumber=0;
                    int groupDicNumber=0;
                    if ([groupDicData objectForKey:@"seachedArray"]!=nil) {
                        seachedArrayNumber=(int)[[groupDicData objectForKey:@"seachedArray"] count];
                    }
                    if ([groupDicData objectForKey:@"groupDic"]!=nil) {
                        groupDicNumber=(int)[[groupDicData objectForKey:@"groupDic"] count];
                    }
                    [cell.cellView2.contentLabel setText:[NSString stringWithFormat:@"%@%d%@,%@%d,%@%d",NSLocalizedStringFromTable(@"LampsView_GroupOne", @"InfoPlist", nil),(int)[[groupDicData objectForKey:@"allGroupNumber"] count],NSLocalizedStringFromTable(@"LampsView_GroupTwo", @"InfoPlist", nil),NSLocalizedStringFromTable(@"LampsView_GroupThree", @"InfoPlist", nil),seachedArrayNumber,NSLocalizedStringFromTable(@"LampsView_GroupFour", @"InfoPlist", nil),groupDicNumber]];
                    [cell.cellView2.nameLabel setText:[groupDicData objectForKey:@"groupName"]];
                }else{
                    [cell.cellView2.nameLabel setText:[groupDicData objectForKey:@"GroupTime"]];
                    [cell.cellView2.contentLabel setText:[NSString stringWithFormat:@"%@%d%@",NSLocalizedStringFromTable(@"LampsView_GroupOne", @"InfoPlist", nil),(int)[[groupDicData objectForKey:@"groupDic"] count],NSLocalizedStringFromTable(@"LampsView_GroupTwo", @"InfoPlist", nil)]];
                }
                
                cell.cellView2.tag=1000+row*rowcellCount+i;
                
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellviewTaped:)];
                [ cell.cellView2 addGestureRecognizer:tapRecognizer];
            }
        }
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}
-(void)cellviewTaped:(UITapGestureRecognizer *)recognizer
{
    
    int tag=(int)[recognizer view].tag-8000;
    if (tag<0) {
        //如果是分组
        tag=(int)[recognizer view].tag-1000;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"peripheralOpration" object:nil userInfo:[self.peripheralArray objectAtIndex:tag]];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        //如果是单个灯
        if (self.peripheralArray.count<tag+1) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"LampsView_DeviceOntFound", @"InfoPlist", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return;
        }
        
        if ([dataArray count]>10) {
            int countConnected=0;
            for (int i=0; i<[dataArray count]; i++)
            {
                CBPeripheral * peripheral = [self.peripheralArray objectAtIndex:i];
                if (peripheral.state!=0)
                {
                    countConnected++;
                    if (countConnected>=10)
                    {
                        [popUpView setText: @"同时连接的最大数目为10个"];
                        [self.view addSubview:popUpView];
                        return;
                    }
                }
            }
        }
        
        CBPeripheral * peripheral = [self.peripheralArray objectAtIndex:tag];
       
        if (peripheral.state==2) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"peripheralOpration" object:peripheral userInfo:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self.cbCentralMgr connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
        }
    }
}
-(void)longPressAction:(UILongPressGestureRecognizer*)sender{
    if(UIGestureRecognizerStateBegan == sender.state) {
        UIAlertView *actionSheet=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"LampsView_SetGroupName", @"InfoPlist", nil) delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        actionSheet.alertViewStyle=UIAlertViewStylePlainTextInput;
        actionSheet.tag=[sender view].tag;
        [actionSheet show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *str=[alertView textFieldAtIndex:0].text;
    int tag=(int)alertView.tag-8000;
    if (self.peripheralArray.count<tag+1) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"LampsView_DeviceOntFound", @"InfoPlist", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    CBPeripheral * peripheral = [self.peripheralArray objectAtIndex:tag];
    
    //查找当前是否已经对这个灯分过组，已分组则移除之前的分组
    [self deleteLightConnectGroup:[peripheral.identifier UUIDString]];
    
    //加入新分组
    for (int i=0; i<[lightConnectGroupArray count]; i++) {
        if ([[[lightConnectGroupArray objectAtIndex:i] objectForKey:@"groupName"] isEqualToString:str]) {
            NSMutableDictionary *dic=[lightConnectGroupArray objectAtIndex:i];
            NSMutableArray *array=[[NSMutableArray alloc]initWithArray:[dic objectForKey:@"uuidArray"]];
            [array addObject:[peripheral.identifier UUIDString]];
            [dic setObject:array forKey:@"uuidArray"];
            [lightConnectGroupArray replaceObjectAtIndex:i withObject:dic];
            
            [userDefaults setObject:lightConnectGroupArray forKey:@"lightConnectGroup"];
            [self.tableViewPeripheral reloadData];
            return;
        }
    }
    //如果没分过，则新增
    NSMutableArray *array=[[NSMutableArray alloc]initWithObjects:[peripheral.identifier UUIDString], nil];
    NSDictionary *dicTem=[[NSDictionary alloc]initWithObjectsAndKeys:array,@"uuidArray",str,@"groupName",[NSNumber numberWithInteger:[lightConnectGroupArray count]],@"groupID",nil];
    [lightConnectGroupArray addObject:dicTem];
    [userDefaults setObject:lightConnectGroupArray forKey:@"lightConnectGroup"];
    [self.tableViewPeripheral reloadData];
}
//根据uuid删除之前的分组
-(void)deleteLightConnectGroup:(NSString*)uuid{
    for (int i=0; i<[lightConnectGroupArray count]; i++) {
        NSMutableDictionary *dic=[lightConnectGroupArray objectAtIndex:i];
        NSMutableArray *array=[[NSMutableArray alloc]initWithArray:[dic objectForKey:@"uuidArray"]];
        for (int j=0; j<[array count]; j++) {
            if ([[array objectAtIndex:j] isEqualToString:uuid]) {
                [array removeObjectAtIndex:j];
                [dic setObject:array forKey:@"uuidArray"];
                [lightConnectGroupArray replaceObjectAtIndex:i withObject:dic];
            }
        }
    }
}

//根据uuid查找到分组名
-(NSString*)seachLightConnectGroup:(NSString*)uuid{
    for (int i=0; i<[lightConnectGroupArray count]; i++) {
        NSArray *array=[[lightConnectGroupArray objectAtIndex:i] objectForKey:@"uuidArray"];
        for (int j=0; j<[array count]; j++) {
            if ([[array objectAtIndex:j] isEqualToString:uuid]) {
                return [[lightConnectGroupArray objectAtIndex:i] objectForKey:@"groupName"];
            }
        }
    }
    return uuid;
}

//获取当前时间
- (NSString *)getCurrentTime
{
    NSDate *dateNow = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat : @"MM-dd HH:mm"];
    return  [formatter stringFromDate:dateNow];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStateUnsupported:
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"State Unsupported！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [self addLog:@"State Unsupported"];
            }
            break;
        default:
            [self addLog:@"本设备支持蓝牙"];
            break;
    }
}
-(void)addLog:(NSString*)log{
    NSLog(@"%@",log);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"发现设备:%@",advertisementData);
    [self addLog:peripheral.name];
    if (!([peripheral.name hasPrefix:@"ADM_"]||[peripheral.name hasPrefix:@"AMD_"])||[[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"] count]==0||![[[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"] objectAtIndex:0] isEqual:[CBUUID UUIDWithString:@"FFF0"]]) {
        NSLog(@"收到不属于adm灯泡的蓝牙4.0设备：%@",peripheral.name);
        return;
    }
    [dataArray addObject:peripheral];
    
    [self thisLightGroupName:peripheral.name uuid:[peripheral.identifier UUIDString]];
    
    //如果当前是
    if (segmentedContol.selectedSegmentIndex==0) {
        //如果是ALL灯泡界面将当泡信息更新到界面
        self.peripheralArray=dataArray;
        [self.tableViewPeripheral reloadData];
    }else{
        //如果是group模式，将最新信息刷新到group界面
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self addLog:@"设备已连上，设置委托为当前视图"];
    [self.tableViewPeripheral reloadData];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self addLog:@"失去连接"];
    [self addLog:peripheral.name];
    [self.tableViewPeripheral reloadData];
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    //这个方法不会被调用，不获取设备相关信息，近获取通信特性信息
    [self addLog:@"获取到设备相关信息"];
    [self addLog:peripheral.name];
    for (CBService * server in service.includedServices) {
        NSLog(@"设备信息:%@",server);
    }
    
}

//返回的蓝牙特征值通知代理
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    [self addLog:@"获取到设备特性"];
    
    for (CBCharacteristic * characteristic in service.characteristics) {
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        
    }
    
    for (CBCharacteristic * characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID_5]])
        {
            char strcommand[12]={'c','*','1','2','3','4','5','6','7','8','h'};
            strcommand[1]=1;
            NSData *cmdData = [NSData dataWithBytes:strcommand length:12];
            NSLog(@"发送认证密码");
            [peripheral writeValue:cmdData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID_4]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        //保留，以后可能用到
//        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID_1]])
//        {
//            char strcommand[9]={'s','*','*','*','*','*','1','e'};
//            strcommand[6]=2;
//            NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
//            [peripheral writeValue:cmdData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
//            NSLog(@"执行开灯写数据操作，读数据之前要一个操作");
//            
//            [peripheral readValueForCharacteristic:characteristic];
//            NSLog(@"读特性获取亮度值");
//        }
    }
}
//peripheral:didUpdateValueForCharacteristic:error
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"%@读取到值，接收到数据：%@",peripheral.name,characteristic);
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
//    NSLog(@"%@写数据:%@",peripheral.name,characteristic.value);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self addLog:@"收到特性状态的更新通知"];
}

//返回的蓝牙服务通知通过代理
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    [self addLog:@"发现蓝牙服务，启动特性搜索"];
    for (CBService* service in peripheral.services)
    {
        //查询服务所带的特征值
        [peripheral discoverCharacteristics:nil forService:service];
        //获取设备信息，保留，以后可能用到
//        [peripheral discoverIncludedServices:nil forService:service];
    }
}
//与当前所有数组中的uuid比较，如果存在，则不添加，如果不存在，则添加到本地保存
-(void )thisLightGroupName:(NSString *)name uuid:(NSString *)uuidStr{
    NSLog(@"thisLightGroupName,%@,%@",name,uuidStr);
    NSMutableArray *allLightArray=[userDefaults objectForKey:@"allLight"];
    for (int i=0; i<[allLightArray count]; i++)
    {
        if ([[allLightArray objectAtIndex:i] objectForKey:@"uuid"]==uuidStr)
        {
            return ;
        }
    }
    NSDictionary *dicTem=[[NSDictionary alloc]initWithObjectsAndKeys:name,@"name",uuidStr,@"uuid", nil];
    [allLightArray addObject:dicTem];
    [userDefaults setObject:allLightArray forKey:@"allLight"];
}

//进入Group模式时，将对应关系数组添加到group数组后面作为固定部分组成显示数据源
-(void)getGroupFromAllConnection{
    
    for (int i=0; i<[lightConnectGroupArray count]; i++)
    {
        //组内所有成员UUIDArray数组
        NSArray *uuidArray=[[lightConnectGroupArray objectAtIndex:i] objectForKey:@"uuidArray"];
        //搜索到的uuid在所有灯泡中的序号数组
        NSDictionary *arrayTem=[self arrayFromUUIDArray:uuidArray];
        if ([arrayTem count])
        {
            //groupDic保存已连接的数组，seachedArray被搜索到的数组，allGroupNumber组内总成员数组
            NSMutableDictionary *groupMember=[[NSMutableDictionary alloc]initWithObjectsAndKeys:[self getCurrentTime],@"GroupTime",@"0",@"liangdu",[[lightConnectGroupArray objectAtIndex:i] objectForKey:@"groupName"],@"groupName",[arrayTem objectForKey:@"groupDic"],@"groupDic",dataArray,@"DataArray",[arrayTem objectForKey:@"seachedArray"],@"seachedArray",uuidArray,@"allGroupNumber",@"1",@"type",nil];
            [self.peripheralArray addObject:groupMember];//将数据加入到显示数据源
        }
    }
    
    NSLog(@"getGroupFromAllConnection:%@",self.peripheralArray);
}

//将uuid数组返回对应于dataArray中的序号，已设定dataArray不会在失去连接时移除数组，只在重新搜索时移除
-(NSDictionary*)arrayFromUUIDArray:(NSArray*)uuidArray{
    //如果某个分组的灯都被删除，加入到了其他分组
    if ([uuidArray count]==0) {
        return nil;
    }
    //groupDicTem保存已连接的数组，seachedArrayTem被搜索到的数组
    NSMutableArray *groupDicTem=[[NSMutableArray alloc]initWithCapacity:0];
    NSMutableArray *seachedArrayTem=[[NSMutableArray alloc]initWithCapacity:0];
    NSLog(@"uuidArray:%@",uuidArray);
    //找到序号数组
    for (int i=0; i<[uuidArray count]; i++) {
        for (int j=0; j<[dataArray count]; j++) {
            CBPeripheral * peripheral=[dataArray objectAtIndex:j];
            if ([[uuidArray objectAtIndex:i] isEqualToString:[peripheral.identifier UUIDString]]) {
                NSLog(@"搜索到：%@,%@",[uuidArray objectAtIndex:i],[peripheral.identifier UUIDString]);
                //找到相等的UUID，即加入seachedArrayTem
                [seachedArrayTem addObject:[NSNumber numberWithInt:j]];
                //如果是连接状态，加入groupDicTem
                if (peripheral.state==2) {
                    [groupDicTem addObject:[NSNumber numberWithInt:j]];
                }
            }
        }
    }
    //groupDic保存已连接的数组，seachedArray被搜索到的数组
    NSDictionary *returnDic=[[NSDictionary alloc]initWithObjectsAndKeys:groupDicTem,@"groupDic",seachedArrayTem,@"seachedArray", nil];
    return returnDic;
}
@end

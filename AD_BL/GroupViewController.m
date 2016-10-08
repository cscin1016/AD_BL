//
//  GroupViewController.m
//  RESideMenuExample
//
//  Created by 3013 on 14-5-30.
//  Copyright (c) 2014年 Roman Efimov. All rights reserved.
//

#import "GroupViewController.h"
#import "PopupView.h"

@interface GroupViewController (){
    NSMutableDictionary *isSelectDic;
}

@end

@implementation GroupViewController
@synthesize AllDataArray,cbCentralMgr;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isSelectDic=[[NSMutableDictionary alloc]init];
    
    self.title=@"CreateGroup";
    if (IS_IOS_7) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_Left.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(BackAction)];
        self.navigationItem.leftBarButtonItem.tintColor=[UIColor whiteColor];
        
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ok"] style:UIBarButtonItemStylePlain target:self action:@selector(selectOverAction)];
        self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
        
    }else{
        UIButton *btnLeft=[UIButton buttonWithType:UIButtonTypeCustom];
        btnLeft.frame=CGRectMake(0, 0, 24, 24);
        [btnLeft setBackgroundImage:[UIImage imageNamed:@"nav_Left.png"] forState:UIControlStateNormal];
        [btnLeft addTarget:self action:@selector(BackAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnLeft];
        
        UIButton *btnRight=[UIButton buttonWithType:UIButtonTypeCustom];
        btnRight.frame=CGRectMake(0, 0, 24, 24);
        [btnRight setBackgroundImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
        [btnRight addTarget:self action:@selector(selectOverAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnRight];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)BackAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//在此处确认是否有选择灯牌，若没选，则不让通过
-(void)selectOverAction{
    BOOL isSelectLight=NO;
    for (int i=0; i<[[isSelectDic allValues] count]; i++) {
        if ([[[isSelectDic allValues] objectAtIndex:i] intValue])
        {
            isSelectLight=YES;
            break;
        }
    }
    if (isSelectLight) {
        //遍历字典，如果没有为1的灯则弹出提示
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ADDGroupOpration" object:isSelectDic userInfo:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"No Light Was Selected!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }
    
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
    return AllDataArray.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (((CBPeripheral*)[AllDataArray objectAtIndex:indexPath.row]).state==2) {
        if ([[isSelectDic objectForKey:[NSNumber numberWithInt:(int)indexPath.row]] integerValue]) {
            [isSelectDic setObject:@"0" forKey:[NSNumber numberWithInt:(int)indexPath.row]];
        }else{
            [isSelectDic setObject:@"1" forKey:[NSNumber numberWithInt:(int)indexPath.row]];
        }
    }else{
        if ([AllDataArray count]>10) {
            int countConnected=0;
            for (int i=0; i<[AllDataArray count]; i++)
            {
                CBPeripheral * peripheral = [AllDataArray objectAtIndex:i];
                if (peripheral.state!=0)
                {
                    countConnected++;
                    if (countConnected>=10)
                    {
                        PopupView  *popUpView;
                        popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 240, 0, 0)];
                        popUpView.ParentView = self.view;
                        [popUpView setText: @"同时连接的最大数目为10个"];
                        [self.view addSubview:popUpView];
                        return;
                    }
                }
            }
        }
        [self.cbCentralMgr connectPeripheral:((CBPeripheral*)[AllDataArray objectAtIndex:indexPath.row]) options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationNone];
    
    //点击完毕，立即恢复颜色
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cell";
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSString *State=nil;
    if (((CBPeripheral*)[AllDataArray objectAtIndex:indexPath.row]).state==0) {
        State=@"disconnected";
        cell.textLabel.textColor=[UIColor blackColor];
    }else if (((CBPeripheral*)[AllDataArray objectAtIndex:indexPath.row]).state==1){
        State=@"Connecting";
        cell.textLabel.textColor=[UIColor blueColor];
    }else{
        State=@"Connected";
        cell.textLabel.textColor=[UIColor blueColor];
    }
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@", [((CBPeripheral*)[AllDataArray objectAtIndex:indexPath.row]).name substringFromIndex:4],State];
    cell.detailTextLabel.text = [((CBPeripheral*)[AllDataArray objectAtIndex:indexPath.row]).identifier UUIDString];
    if ([[isSelectDic objectForKey:[NSNumber numberWithInt:(int)indexPath.row]] integerValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

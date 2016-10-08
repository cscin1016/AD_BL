//
//  MeunViewController.m
//  Foodspotting
//
//  Created by jetson  on 12-8-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MeunViewController.h"
#import "DDMenuController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "BrignessVC.h"
#import "MusicTestViewController.h"
#import "RemoteVC.h"
#import "CSCViewController.h"
#import "TimerVC.h"
#import "XIDingDeng.h"
#import "RecordVC.h"
#import "musicModle.h"


@interface MeunViewController (){

    BrignessVC *ColorAndBright;
    MusicTestViewController *MusicMode;
    RemoteVC *RemoteMode;
    CSCViewController *ImageColor;
    TimerVC *TimerViewController;
    XIDingDeng *CeilingLight;
    RecordVC *microphone;
    musicModle *newMusicView;
}

@end

@implementation MeunViewController

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
    // Do any additional setup after loading the view from its nib.
	
	list = [[NSMutableArray alloc]init];
    [list addObject:NSLocalizedStringFromTable(@"LISTOBJ1", @"InfoPlist", nil)];
    [list addObject:NSLocalizedStringFromTable(@"LISTOBJ2", @"InfoPlist", nil)];
    [list addObject:NSLocalizedStringFromTable(@"LISTOBJ3", @"InfoPlist", nil)];
    [list addObject:NSLocalizedStringFromTable(@"LISTOBJ4", @"InfoPlist", nil)];
    [list addObject:NSLocalizedStringFromTable(@"LISTOBJ5", @"InfoPlist", nil)];
    [list addObject:NSLocalizedStringFromTable(@"LISTOBJ6", @"InfoPlist", nil)];
    [list addObject:NSLocalizedStringFromTable(@"LISTOBJ7", @"InfoPlist", nil)];
    [list addObject:NSLocalizedStringFromTable(@"LISTOBJ8", @"InfoPlist", nil)];
//    [list addObject:@"New Music"];
    
    
    ColorAndBright=[[BrignessVC alloc]init];
    MusicMode=[[MusicTestViewController alloc]init];
    RemoteMode=[[RemoteVC alloc]init];
    ImageColor=[[CSCViewController alloc]init];
    TimerViewController=[[TimerVC alloc]init];
    CeilingLight=[[XIDingDeng alloc]init];
    microphone=[[RecordVC alloc]init];
    newMusicView=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]  instantiateViewControllerWithIdentifier:@"musicModle"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#define macro ===========tableView============

//选中Cell响应事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	// set the root controller
    DDMenuController *menuController = (DDMenuController*)((AppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
	
	if(indexPath.row==0){
		[menuController setRootController:(DDMenuController*)((AppDelegate *)[[UIApplication sharedApplication] delegate]).viewController animated:YES];
	}else if(indexPath.row ==1){

		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:ColorAndBright];
		[menuController setRootController:navController animated:YES];
	
	}else if(indexPath.row ==2){
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:MusicMode];
		[menuController setRootController:navController animated:YES];
		
	}else if(indexPath.row ==3){
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:RemoteMode];
		[menuController setRootController:navController animated:YES];
	
	}else if(indexPath.row ==4){
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:ImageColor];
		[menuController setRootController:navController animated:YES];
    }else if (indexPath.row==5){
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:TimerViewController];
		[menuController setRootController:navController animated:YES];
    }else if(indexPath.row==6){
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:CeilingLight];
		[menuController setRootController:navController animated:YES];
    }else if (indexPath.row==7){
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:microphone];
		[menuController setRootController:navController animated:YES];
    }else if (indexPath.row==8){
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newMusicView];
		[menuController setRootController:navController animated:YES];
    }

	
    //点击完毕，立即恢复颜色
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
    
}
//返回TableView中有多少数据
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [list count];
    
}
//返回有多少个TableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//组装每一条的数据
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CustomCellIdentifier =@"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    if (cell ==nil) {
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CustomCellIdentifier];
    }
	cell.textLabel.text = [list objectAtIndex:indexPath.row];
    cell.textLabel.textColor=[UIColor whiteColor];
    return cell;
    
}
@end

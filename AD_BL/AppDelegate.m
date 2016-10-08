//
//  AppDelegate.m
//  AD_BL
//
//  Created by 3013 on 14-6-5.
//  Copyright (c) 2014年 com.aidian. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MeunViewController.h"
#import "DDMenuController.h"
#import "iflyMSC/iflySetting.h"


@implementation AppDelegate
@synthesize viewController = _viewController;
@synthesize menuController = _menuController;
@synthesize leftMenu=_leftMenu;

+ (NSInteger)OSVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

-(void)RegistCallCenter{
    //电话监听
    callCenter = [[CTCallCenter alloc] init];
    
    callCenter.callEventHandler =^(CTCall* inCTCall) {
        if ([inCTCall.callState isEqualToString: CTCallStateConnected]) {
            //接通 正在通话
            char strcommand[9]={'s','#','#','#','#','*','f','e'};
            
            strcommand[6] =3;
            strcommand [1] =255-0; //reg
            strcommand [2] =255-255; //green
            strcommand [3] =255-0; //blue
            strcommand [4] =255-255;  //white
            
            NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
        } else if ([inCTCall.callState isEqualToString: CTCallStateDialing]) {
            // 呼叫状态,在建立连接之前,当用户发起呼叫。
            char strcommand[9]={'s','#','#','#','#','*','f','e'};
            
            strcommand[6] =3;
            strcommand [1] =255-0; //reg
            strcommand [2] =255-0; //green
            strcommand [3] =255-255; //blue
            strcommand [4] =255-255;  //white
            
            NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
        } else if ([inCTCall.callState isEqualToString: CTCallStateDisconnected]) {
            //挂断
            NSLog(@"CTCallStateDisconnected");
            char strcommand[9]={'s','*','*','*','*','*','1','e'};
            strcommand[6]=2;
            NSData *cmdData = [NSData dataWithBytes:strcommand length:8];
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
            
        } else if ([inCTCall.callState isEqualToString: CTCallStateIncoming]) {
            //来电提醒
            char strcommand[9]={'s','*','*','*','*','*','1','e'};
            strcommand[6]=1;
            NSData *cmdData = [NSData dataWithBytes:strcommand length:8];
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
        }
        
    };
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
   
    [self RegistCallCenter];
    
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSLog(@"carrier:%@", [carrier description]);
    
    
    self.bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskId];
        self.bgTaskId = UIBackgroundTaskInvalid;
    }];
    
    
    
    [IFlySetting setLogFile:LVL_NONE];
    [IFlySetting showLogcat:YES];
    
    _viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]  instantiateViewControllerWithIdentifier:@"ViewControll"];
    _menuController = [DDMenuController sharedInstance];
    _leftMenu = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]  instantiateViewControllerWithIdentifier:@"menuControll"];
    
    if (IS_IOS_7) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"title_bg_ios7"] stretchableImageWithLeftCapWidth:0 topCapHeight:1] forBarMetrics:UIBarMetricsDefault];
    }else{
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"title_bg"] stretchableImageWithLeftCapWidth:0 topCapHeight:1] forBarMetrics:UIBarMetricsDefault];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:0 forKey:@"numberOfLight"];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

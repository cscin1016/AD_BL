//
//  RemoteVC.m
//  ADM_Lights
//
//  Created by admin on 14-3-5.
//  Copyright (c) 2014年 admin. All rights reserved.
//
#import "addSceneVC.h"

#define DefaultButtonNum 8
#define DefaultRowNum 3
#define DefaultColumnNum 3

#define BrightButtonTag 101
#define CoolButtonTag 102
#define FestiveButtonTag 103
#define NightButtonTag 104
#define ReadButtonTag 105
#define RepeatButtonTag 106
#define SkinButtonTag 107
#define SpringButtonTag 108
#define WarmButtonTag 109
#import "RemoteVC.h"
//#import "ConstsConfig.h"
@interface RemoteVC ()
{
    NSTimer *timer1 ;

}

@end

@implementation RemoteVC

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
    
    //背景图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"app_bg"];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    
    [self createButton];
    [self addButtonClick];
}

-(void)addClick
{
    NSLog(@"添加场景");
    addSceneVC * addscene =[[addSceneVC alloc] init];
    [self.navigationController pushViewController:addscene animated:YES];
}
-(void)viewDidAppear:(BOOL)animated{
    self.title=@"Scene";
    
    if (IS_IOS_7) {
        self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClick)];
        self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
    }else {
        UIButton *btnRight=[UIButton buttonWithType:UIButtonTypeCustom];
        btnRight.frame=CGRectMake(0, 0, 24, 24);
        [btnRight setBackgroundImage:[UIImage imageNamed:@"add4"] forState:UIControlStateNormal];
        [btnRight addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btnRight];
    }
}

#pragma mark button method
-(void)createButton
{
    int tagArray[] = {BrightButtonTag,CoolButtonTag,FestiveButtonTag,NightButtonTag,
    ReadButtonTag,RepeatButtonTag,SkinButtonTag,SpringButtonTag,WarmButtonTag};
    NSArray *titleArray = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"SCENES_Button1",@"InfoPlist", nil),NSLocalizedStringFromTable(@"SCENES_Button2",@"InfoPlist", nil),NSLocalizedStringFromTable(@"SCENES_Button3",@"InfoPlist", nil),NSLocalizedStringFromTable(@"SCENES_Button4",@"InfoPlist", nil),NSLocalizedStringFromTable(@"SCENES_Button5",@"InfoPlist", nil),NSLocalizedStringFromTable(@"SCENES_Button6",@"InfoPlist", nil),NSLocalizedStringFromTable(@"SCENES_Button7",@"InfoPlist", nil),NSLocalizedStringFromTable(@"SCENES_Button8",@"InfoPlist", nil),NSLocalizedStringFromTable(@"SCENES_Button9",@"InfoPlist", nil), nil];
    NSArray *imageArray = [NSArray arrayWithObjects:@"scene_bright",@"scene_read",@"scene_warm",@"scene_spring",@"scene_cool",@"scene_festive",@"scene_night",@"scene_skin",@"scene_repeat", nil];
    for(int i =0 ;i <DefaultButtonNum;i++)
    {
        CGFloat width = 64.f , height = 64.f;
        CGFloat space = 27.f;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button setBackgroundImage:[UIImage imageNamed:@"more_icon_background.png"] forState:UIControlStateNormal];
        
        [button setBackgroundImage:[UIImage imageNamed:@"more_icon_background.png"] forState:UIControlStateHighlighted];  //more_icon_highlight.png
        if (isiPhone4) {
            if (i%DefaultColumnNum == 0 ) {
                button.frame = CGRectMake(27.0, i/DefaultRowNum*(height+space+7)+space+20, width, height);
                button.tag = tagArray[i];
                
            }else if (i%DefaultColumnNum == 2 ) {
                button.frame = CGRectMake(229.0,i/DefaultRowNum*(height+space+7)+space+20, width, height);
                button.tag = tagArray[i];
                
            }else {
                button.frame = CGRectMake(128.0, i/DefaultRowNum*(height+space+7)+space+20, width, height);
                button.tag = tagArray[i];
            }
        }else
            
            if (i%DefaultColumnNum == 0 ) {
                button.frame = CGRectMake(27.0, i/DefaultRowNum*(height+space+7)+space+40, width, height);
                button.tag = tagArray[i];
                
            }else if (i%DefaultColumnNum == 2 ) {
                button.frame = CGRectMake(229.0,i/DefaultRowNum*(height+space+7)+space+40, width, height);
                button.tag = tagArray[i];
                
            }else {
                button.frame = CGRectMake(128.0, i/DefaultRowNum*(height+space+7)+space+40, width, height);
                button.tag = tagArray[i];
            }
        

        [button setImage:[UIImage imageNamed:[imageArray objectAtIndex:i]] forState:UIControlStateNormal];
        [self.view addSubview:button];
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(button.frame.origin.x-6, button.frame.origin.y+height, button.frame.size.width+12,20.f);
        label.text = [titleArray objectAtIndex:i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:14];
        label.backgroundColor = [UIColor clearColor];
        label.textColor =[UIColor whiteColor];
        [self.view addSubview:label];
        
    }
}

-(void)addButtonClick
{
    UIButton *homeBtn = (UIButton *)[self.view viewWithTag:BrightButtonTag];
    [homeBtn addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *videoBtn = (UIButton *)[self.view viewWithTag:CoolButtonTag];
    [videoBtn addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *findBtn = (UIButton *)[self.view viewWithTag:FestiveButtonTag];
    [findBtn addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *officialBtn = (UIButton *)[self.view viewWithTag:NightButtonTag];
    [officialBtn addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *feedbackBtn = (UIButton *)[self.view viewWithTag:ReadButtonTag];
    [feedbackBtn addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *kindergartenBtn = (UIButton *)[self.view viewWithTag:RepeatButtonTag];
    [kindergartenBtn addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *setBtn = (UIButton *)[self.view viewWithTag:SkinButtonTag];
    [setBtn addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *helpBtn = (UIButton *)[self.view viewWithTag:SpringButtonTag];
    [helpBtn addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *quitBtn = (UIButton *)[self.view viewWithTag:WarmButtonTag];
    [quitBtn addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
}


-(void)ButtonClick:(id)sender
{
    
    
    UIButton *btn=(UIButton*)sender;
    char strcommand[9]={'s','#','#','#','#','*','f','e'};
    strcommand[6] =4;
    
    if(btn.tag==101){
        strcommand [1] =0; //reg
        strcommand [2] =0; //green
        strcommand [3] =0; //blue
        strcommand [4] =0;  //white
    }else if (btn.tag==102){
        strcommand [1] =255; //reg
        strcommand [2] =255; //green
        strcommand [3] =255; //blue
        strcommand [4] =0;  //white
    }else if(btn.tag==103){
        strcommand [1] =128; //reg
        strcommand [2] =255; //green
        strcommand [3] =255; //blue
        strcommand [4] =0;  //white
    }else if (btn.tag==104){
        strcommand [1] =255; //reg
        strcommand [2] =0; //green
        strcommand [3] =255; //blue
        strcommand [4] =255;  //white
    }else if (btn.tag==105){
        strcommand [1] =128; //reg
        strcommand [2] =0; //green
        strcommand [3] =128; //blue
        strcommand [4] =0;  //white
    }else if (btn.tag==106){
        strcommand [1] =0; //reg
        strcommand [2] =255; //green
        strcommand [3] =255; //blue
        strcommand [4] =0;  //white
    }else if (btn.tag==107){
        strcommand [1] =255; //reg
        strcommand [2] =255; //green
        strcommand [3] =255; //blue
        strcommand [4] =155;  //white
    }else if (btn.tag==108){
        strcommand [1] =0; //reg
        strcommand [2] =255; //green
        strcommand [3] =255; //blue
        strcommand [4] =128;  //white
    }else{
        
    }
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
    
}


@end

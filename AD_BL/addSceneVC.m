//
//  addSceneVC.m
//  ADM_Lights
//
//  Created by admin on 14-5-29.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import "addSceneVC.h"


@interface addSceneVC (){
    UIButton *RedButton;
    UIButton *GreenButton;
    UIButton *BlueButton;
    UIButton *WhiteButton;
    
    int iReg;
    int igreen;
    int iBlue;
    int iWhite;
    
    UISlider *redSlider;
    UISlider *greenSlider;
    UISlider *blueSlider;
    UISlider *whiteSlider;
    
    NSDate *LastSendTime;
    
    UILabel *redValue;
    UILabel *greenValue;
    UILabel *blueValue;
    UILabel *whiteVlaue;
}

@end

@implementation addSceneVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)BackAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    LastSendTime= [[NSDate alloc]init];
    
    //背景图
    UIImage *bgImage = [UIImage imageNamed:@"app_bg"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
     [self setTitle:@"Add Scene"];
    
    if (IS_IOS_7) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_Left.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(BackAction)];
        self.navigationItem.leftBarButtonItem.tintColor=[UIColor whiteColor];
        
//        //导航item
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered  target:self action:@selector(save)];
//        self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
        
    }else{
        UIButton *btnLeft=[UIButton buttonWithType:UIButtonTypeCustom];
        btnLeft.frame=CGRectMake(0, 0, 24, 24);
        [btnLeft setBackgroundImage:[UIImage imageNamed:@"nav_Left.png"] forState:UIControlStateNormal];
        [btnLeft addTarget:self action:@selector(BackAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnLeft];
        
//        UIButton *btnRight=[UIButton buttonWithType:UIButtonTypeCustom];
//        btnRight.frame=CGRectMake(0, 0, 40, 24);
//        [btnRight setTitle:@"Save" forState:UIControlStateNormal];
//        [btnRight addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnRight];
        
    }
    
    
    
    
    RedButton=[UIButton buttonWithType:UIButtonTypeCustom];
    RedButton.frame=CGRectMake(10, 20, 60, 40);
    RedButton.backgroundColor=[UIColor redColor];
    [RedButton addTarget:self action:@selector(redButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:RedButton];
    

    GreenButton=[UIButton buttonWithType:UIButtonTypeCustom];
    GreenButton.frame=CGRectMake(90, 20, 60, 40);
    GreenButton.backgroundColor=[UIColor greenColor];
    [GreenButton addTarget:self action:@selector(greenButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:GreenButton];
    
    
    BlueButton=[UIButton buttonWithType:UIButtonTypeCustom];
    BlueButton.frame=CGRectMake(170, 20, 60, 40);
    BlueButton.backgroundColor=[UIColor blueColor];
    [BlueButton addTarget:self action:@selector(blueButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:BlueButton];
    
    
    WhiteButton=[UIButton buttonWithType:UIButtonTypeCustom];
    WhiteButton.frame=CGRectMake(250, 20, 60, 40);
    WhiteButton.backgroundColor=[UIColor whiteColor];
    [WhiteButton setTitle:@"关" forState:UIControlStateNormal];
    [WhiteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [WhiteButton addTarget:self action:@selector(whiteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:WhiteButton];
    
   
    
    
    UILabel *label1=[[UILabel alloc]initWithFrame:CGRectMake(10, 80, 60, 40)];
    label1.text=@"Red:";
    label1.textColor=[UIColor whiteColor];
    label1.backgroundColor=[UIColor clearColor];
    [self.view addSubview:label1];
    
    
    
    UILabel *label2=[[UILabel alloc]initWithFrame:CGRectMake(10, 130, 60, 40)];
    label2.text=@"Green:";
    label2.textColor=[UIColor whiteColor];
    label2.backgroundColor=[UIColor clearColor];
    [self.view addSubview:label2];
    
    
    UILabel *label3=[[UILabel alloc]initWithFrame:CGRectMake(10, 180, 60, 40)];
    label3.text=@"Blue:";
    label3.textColor=[UIColor whiteColor];
    label3.backgroundColor=[UIColor clearColor];
    [self.view addSubview:label3];
    
    
    UILabel *label4=[[UILabel alloc]initWithFrame:CGRectMake(10, 230, 60, 40)];
    label4.text=@"White:";
    label4.textColor=[UIColor whiteColor];
    label4.backgroundColor=[UIColor clearColor];
    [self.view addSubview:label4];
   

    redSlider=[[UISlider alloc]initWithFrame:CGRectMake(80, 80, 200, 40)];
    redSlider.value=255;
    redSlider.tag=0;
    redSlider.minimumValue=0;
    redSlider.maximumValue=255;
    redSlider.continuous = YES;
    [redSlider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:redSlider];
    
    
    greenSlider=[[UISlider alloc]initWithFrame:CGRectMake(80, 130, 200, 40)];
    greenSlider.value=255;
    greenSlider.minimumValue=0;
    greenSlider.maximumValue=255;
    greenSlider.tag=1;
    [greenSlider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:greenSlider];
    
    blueSlider=[[UISlider alloc]initWithFrame:CGRectMake(80, 180, 200, 40)];
    blueSlider.value=255;
    blueSlider.minimumValue=0;
    blueSlider.maximumValue=255;
    blueSlider.tag=2;
    [blueSlider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:blueSlider];
    
    whiteSlider=[[UISlider alloc]initWithFrame:CGRectMake(80, 230, 200, 40)];
    whiteSlider.value=255;
    whiteSlider.minimumValue=0;
    whiteSlider.maximumValue=255;
    whiteSlider.tag=3;
    [whiteSlider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:whiteSlider];
    
    redValue=[[UILabel alloc]initWithFrame:CGRectMake(285, 80, 30, 40)];
    redValue.text=@"0";
    redValue.textColor=[UIColor whiteColor];
    redValue.backgroundColor=[UIColor clearColor];
    [self.view addSubview:redValue];
    
    greenValue=[[UILabel alloc]initWithFrame:CGRectMake(285, 130, 30, 40)];
    greenValue.text=@"0";
    greenValue.textColor=[UIColor whiteColor];
    greenValue.backgroundColor=[UIColor clearColor];
    [self.view addSubview:greenValue];
    
    blueValue=[[UILabel alloc]initWithFrame:CGRectMake(285, 180, 30, 40)];
    blueValue.text=@"0";
    blueValue.textColor=[UIColor whiteColor];
    blueValue.backgroundColor=[UIColor clearColor];
    [self.view addSubview:blueValue];
    
    whiteVlaue=[[UILabel alloc]initWithFrame:CGRectMake(285, 230, 30, 40)];
    whiteVlaue.text=@"0";
    whiteVlaue.textColor=[UIColor whiteColor];
    whiteVlaue.backgroundColor=[UIColor clearColor];
    [self.view addSubview:whiteVlaue];
    
    UIButton *nameBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    nameBtn.frame=CGRectMake(40, 280, 80, 40);
    [nameBtn setTitle:@"设置图片" forState:UIControlStateNormal];
    [nameBtn addTarget:self action:@selector(selectPicture) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:nameBtn];
    
    
}
-(void)selectPicture{
    
}
-(void)updateValue:(id)sender{
    if ([LastSendTime timeIntervalSinceNow]<-0.15) {
        LastSendTime=[[NSDate alloc]init];
    }else{
        return;
    }
    
    if(((UISlider*)sender).tag==0){
        iReg=((UISlider*)sender).value;
        redValue.text=[NSString stringWithFormat:@"%d",iReg];
//        whiteSlider.value=0;  //RGB开的时候，白光关闭
//        iWhite =0;
    }else if (((UISlider*)sender).tag==1){
//        whiteSlider.value=0;  //RGB开的时候，白光关闭
//        iWhite =0;
        igreen=((UISlider*)sender).value;
        greenValue.text=[NSString stringWithFormat:@"%d",igreen];
    }else if (((UISlider*)sender).tag==2){
//        whiteSlider.value=0;  //RGB开的时候，白光关闭
//        iWhite =0;
        iBlue=((UISlider*)sender).value;
        blueValue.text=[NSString stringWithFormat:@"%d",iBlue];
    }else if (((UISlider*)sender).tag==3){
        iWhite=((UISlider*)sender).value; //白光开的时候，其他RGB关闭
        whiteVlaue.text=[NSString stringWithFormat:@"%d",iWhite];
    }
    char strcommand[8]={'s','r','g','b','w','B','#','e'};
    strcommand [1] =255-iReg; //reg
    strcommand [2] =255-igreen; //green
    strcommand [3] =255-iBlue; //blue
    strcommand [4] =255-iWhite;  //white
    strcommand[6] =3;
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:8];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];

    
}
-(void)redButtonAction{
    NSLog(@"redButtonAction");
    iReg=255;
    igreen=0;
    iBlue=0;
    
    redSlider.value=255;
    greenSlider.value=0;
    blueSlider.value=0;

    char strcommand[8]={'s','#','#','#','#','*','f','e'};
    strcommand [1] =0; //reg
    strcommand [2] =255; //green
    strcommand [3] =255; //blue
    strcommand [4] =255-iWhite;  //white
    strcommand[6] =3;
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:8];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
}
-(void)greenButtonAction{
    NSLog(@"greenButtonAction");
    iReg=0;
    igreen=255;
    iBlue=0;
    
    redSlider.value=0;
    greenSlider.value=255;
    blueSlider.value=0;
    
    char strcommand[8]={'s','#','#','#','#','*','f','e'};
    strcommand [1] =255; //reg
    strcommand [2] =0; //green
    strcommand [3] =255; //blue
    strcommand [4] =255-iWhite;  //white
    strcommand[6] =3;
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:8];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];

}

-(void)blueButtonAction{
    NSLog(@"blueButtonAction");
    
    iReg=0;
    igreen=0;
    iBlue=255;
    
    redSlider.value=0;
    greenSlider.value=0;
    blueSlider.value=255;
    
    
    char strcommand[8]={'s','#','#','#','#','*','f','e'};
    strcommand [1] =255; //reg
    strcommand [2] =255; //green
    strcommand [3] =0; //blue
    strcommand [4] =255-iWhite;  //white
    strcommand[6] =3;
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:8];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];

}

-(void)whiteButtonAction{
    
    if(iWhite==0){
        iWhite=255;
        whiteSlider.value=255;
        [WhiteButton setTitle:@"on" forState:UIControlStateNormal];
    }else{
        iWhite=0;
        whiteSlider.value=0;
        [WhiteButton setTitle:@"off" forState:UIControlStateNormal];
    }
    [WhiteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

-(void)save
{
    [self.navigationController popViewControllerAnimated:YES];
    if (iReg==0&&igreen==0&&iBlue==0&&iWhite==0) {
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Alert"  message:@"Save failed！Please select a color!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }else
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
        NSMutableArray *arr=[[NSMutableArray alloc]initWithArray:[userDefault objectForKey:@"Scence"]];
        NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:iReg],@"red",[NSNumber numberWithInt:igreen],@"green",[NSNumber numberWithInt:iBlue],@"blue",[NSNumber numberWithInt:iWhite],@"white", nil];
        [arr addObject:dic];
        [userDefault setObject:arr forKey:@"Scence"];
    }
}

@end

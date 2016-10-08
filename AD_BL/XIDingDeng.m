//
//  XIDingDeng.m
//  AD_BL
//
//  Created by apple on 14-6-14.
//  Copyright (c) 2014年 com.aidian. All rights reserved.
//

#import "XIDingDeng.h"
#import "draw_graphic.h"

@interface XIDingDeng (){
    draw_graphic *myView;
    UIImageView *sanjiaoView;
    
    NSDate *InAreaTime;
    int inAreaNumber;
    float jiaodu;
    UIImageView *imageTip;
    int selectButton;
    NSTimer *MyTimer;
}

@end

@implementation XIDingDeng

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
    selectButton=1;
    // Do any additional setup after loading the view.
    
    InAreaTime=[[NSDate alloc]init];
    //背景图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"app_bg"];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    
    
    //调亮图
    UIImageView *brightView = [[UIImageView alloc] initWithFrame:CGRectMake(-18, 17, 360, 350)];
    brightView.image = [UIImage imageNamed:@"圈"];
    [self.view addSubview:brightView];
    
    //调亮图
    sanjiaoView= [[UIImageView alloc] initWithFrame:CGRectMake(-18, 17, 360, 350)];
    sanjiaoView.image = [UIImage imageNamed:@"三角(1)"];
    [self.view addSubview:sanjiaoView];
    sanjiaoView.transform=CGAffineTransformMakeRotation(-3.1415926*42/180);
    
    CGRect initr=CGRectMake(26, 54, 272, 272);
    myView=[[draw_graphic alloc] initWithFrame:initr];
    myView.opaque=YES;
    myView.userInteractionEnabled=NO;
    myView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:myView];
    
    myView.transform=CGAffineTransformMakeRotation(3.1415926*120/180);
    

    UIButton *blueButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [blueButton setBackgroundImage:[UIImage imageNamed:@"1.png"] forState:UIControlStateNormal];
    
    [blueButton addTarget:self action:@selector(blueButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [blueButton setFrame:CGRectMake(49, 86, 100, 210)];
    [self.view addSubview:blueButton];
    
    UIButton *whiteButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [whiteButton setBackgroundImage:[UIImage imageNamed:@"2.png"] forState:UIControlStateNormal];
//    [whiteButton addTarget:self action:@selector(whiteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [whiteButton setFrame:CGRectMake(113, 79, 170, 111)];
    [self.view addSubview:whiteButton];
    
    UIButton *yellowButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [yellowButton setBackgroundImage:[UIImage imageNamed:@"3.png"] forState:UIControlStateNormal];
    [yellowButton addTarget:self action:@selector(yellowButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [yellowButton setFrame:CGRectMake(123, 190, 150, 113)];
    
    [self.view addSubview:yellowButton];
    
    MyTimer=[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(sendMessage) userInfo:nil repeats:YES];
    
}
-(void)blueButtonAction{
    selectButton=1;
}
-(void)whiteButtonAction{
    selectButton=2;
}
-(void)yellowButtonAction{
    selectButton=0;
}
-(void)viewWillAppear:(BOOL)animated{
    
    self.title=@"CeilingLight";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    imageTip.center=point;
    int x = point.x;
    int y = point.y;
    
    [self touchDraw:x :y ];
}
-(void)touchDraw:(int)x :(int)y {
    
    if (x==162&&y>190) {
        return;
    }
    float jiaoduTem=atan((y-190)*1.0/(x-162))*180.0/3.1415926;
    
    if (x<=162) {
        jiaoduTem+=60;
    }else if(x>162){
        jiaoduTem+=240;
    }
    if (jiaoduTem<0||jiaoduTem>305) {
        return;
    }
    if(jiaoduTem>295)jiaodu=303;
    else jiaodu=(int)jiaoduTem/20*20;
    
    sanjiaoView.transform=CGAffineTransformMakeRotation(3.1415926*(jiaodu-42)/180);
    int tempReg,tempBlue,tempGreen;
    
    if (selectButton==0) {//黄色
        tempReg=210;
        tempGreen=218;
        tempBlue=65;
        
    }else if (selectButton==1){//蓝色
        tempReg=129;
        tempGreen=137;
        tempBlue=239;
        
    }else if (selectButton==2){//白色
        tempReg=255;
        tempGreen=255;
        tempBlue=255;
    }
    
    myView.height=jiaodu;
    myView.red=tempReg*jiaodu/303.0;
    myView.green=tempGreen*jiaodu/303.0;
    myView.blue=tempBlue*jiaodu/303.0;
    [myView setNeedsDisplay];
    
}

-(void)sendMessage{
    
    char strcommand[9]={'s','R','G','B','W','*','f','e'};
    float tempJD=0;
    switch ((int)jiaodu/19) {
        case 0:
            tempJD=0*303;
            break;
        case 1:
            tempJD=0.03*303;
            break;
        case 2:
            tempJD=0.07*303;
            break;
        case 3:
            tempJD=0.11*303;
            break;
        case 4:
            tempJD=0.14*303;
            break;
        case 5:
            tempJD=0.19*303;
            break;
        case 6:
            tempJD=0.24*303;
            break;
        case 7:
            tempJD=0.29*303;
            break;
        case 8:
            tempJD=0.35*303;
            break;
        case 9:
            tempJD=0.4*303;
            break;
        case 10:
            tempJD=0.47*303;
            break;
        case 11:
            tempJD=0.53*303;
            break;
        case 12:
            tempJD=0.64*303;
            break;
        case 13:
            tempJD=0.75*303;
            break;
        case 14:
            tempJD=0.87*303;
            break;
        case 15:
            tempJD=1*303;
            break;
        default:
            tempJD=1*303;
            break;
    }
//    NSLog(@"(int)jiaodu/19:%d",(int)jiaodu/20);
//    strcommand[1] =(int)jiaodu/20;
//    strcommand[2] =(int)jiaodu/20;
    if (selectButton==0) {//黄色
        strcommand[1] =255;
        strcommand[2] = (int)(255*(1-tempJD/303));
    }else if (selectButton==1){//蓝色
        strcommand[1] =(int)(255*(1-tempJD/303));
        strcommand[2] =255;
    }else if (selectButton==2){//白色
        strcommand[1] =(int)(255*(1-tempJD/303));
        strcommand[2] =(int)(255*(1-tempJD/303));
    }
    
    strcommand[6] =4;//保存
   
    
//    if(inAreaNumber!=(int)tempJD/16){
//        NSLog(@"新的一格");
//        InAreaTime=[[NSDate alloc]init];
//        inAreaNumber=(int)tempJD/16;
//        return;
//    }
    
//    if ([InAreaTime timeIntervalSinceNow]<-0.10) {
//        InAreaTime=[[NSDate alloc]init];
//    }else{
//        NSLog(@"时间太短");
//        return;
//    }
    
//    NSLog(@"中间发送");
    NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    imageTip.center=point;
    int x = point.x;
    int y = point.y;
    
    [self touchDraw:x :y ];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    imageTip.center=point;
    int x = point.x;
    int y = point.y;
    
    [self touchDraw:x :y];
    
}
@end

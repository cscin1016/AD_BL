//
//  BrignessVC.m
//  ADM_Lights
//
//  Created by admin on 14-3-7.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import "BrignessVC.h"

#import "EFCircularSlider.h"



@interface BrignessVC ()
{
    EFCircularSlider *colorSlider;
    UIImageView *sanjiaoView;
    NSDate *LastSendTime;
    float jiaodu;
    float LastJD;
    UISlider *bottomSlide;
    UIImageView *slideInImage;
    UIImageView *slideImageView;
    
    int iReg;
    int igreen;
    int iBlue;
    int iWhite;
    
    draw_graphic *myView;
    UILabel *valueLabel;
    UILabel *whiteSetLabel;
}

@end

@implementation BrignessVC
@synthesize delegate;

-(void)dealloc
{
    self.delegate=nil;
    [super dealloc];
}
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
    
    LastSendTime= [[NSDate alloc]init];
    jiaodu=1;
    
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
    
    
    
    //调色版板图
    UIImage *colorImage = [UIImage imageNamed:@"color_pl"];
    UIImageView *colorImageView  = [[UIImageView alloc] initWithImage:colorImage];
    colorImageView.frame =CGRectMake(30,60, colorImage.size.width, colorImage.size.height);
    colorImageView.userInteractionEnabled = YES;
    [self.view addSubview:colorImageView];
   
    
    //白色开关按钮
    UIImage *minImage = [UIImage imageNamed:@"color_bulb_x"];
    UIButton *offbt =[UIButton buttonWithType:UIButtonTypeCustom];
    [offbt setBackgroundImage:minImage forState:UIControlStateNormal];
    offbt.frame =CGRectMake(colorImageView.frame.size.width/2-10,colorImageView.frame.size.height/2+19, minImage.size.width-1, minImage.size.height-1);
    [offbt addTarget:self action:@selector(offbtClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:offbt];



    
    //slider控制器
    CGRect minuteSliderFrame =CGRectMake(45,40, colorImage.size.width*0.7, colorImage.size.height*0.7);
    colorSlider = [[EFCircularSlider alloc] initWithFrame:minuteSliderFrame];

    colorSlider.unfilledColor = [UIColor clearColor];
    colorSlider.filledColor = [UIColor clearColor];
    colorSlider.lineWidth = 8;
    colorSlider.minimumValue = 0;
    colorSlider.maximumValue = 360;
    colorSlider.labelColor = [UIColor colorWithRed:76/255.0f green:111/255.0f blue:137/255.0f alpha:1.0f];
    colorSlider.handleType = doubleCircleWithOpenCenter;
    colorSlider.handleColor = [UIColor whiteColor];
    [colorImageView addSubview:colorSlider];
    [colorSlider addTarget:self action:@selector(colorDidChange:) forControlEvents:UIControlEventValueChanged];
    
    
    //label的背景框
    UIImageView *labelBg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"label_bg1"]];
    labelBg.frame=CGRectMake(235, 13, 58, 24);
    labelBg.backgroundColor=[UIColor clearColor];
    [self.view addSubview:labelBg];
    
    
    //显示多少角度
    valueLabel =[[UILabel alloc] initWithFrame:CGRectMake(235,15,60, 20)];
    valueLabel.backgroundColor=[UIColor clearColor];
    valueLabel.textAlignment  =NSTextAlignmentCenter;
    valueLabel.textColor =[UIColor whiteColor];
    valueLabel.font=[UIFont systemFontOfSize:12];
    valueLabel.text=@"1%";
    [self.view addSubview:valueLabel];
    
    //label的背景框
    labelBg=nil;
    labelBg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"label_bg1"]];
    labelBg.frame=CGRectMake(25, 13, 58, 24);
    labelBg.backgroundColor=[UIColor clearColor];
    [self.view addSubview:labelBg];
    
    
    //显示多少角度
    whiteSetLabel=[[UILabel alloc] initWithFrame:CGRectMake(25,15,60, 20)];
    whiteSetLabel.backgroundColor=[UIColor clearColor];
    whiteSetLabel.textAlignment  =NSTextAlignmentCenter;
    whiteSetLabel.textColor =[UIColor whiteColor];
    whiteSetLabel.font=[UIFont systemFontOfSize:12];
    whiteSetLabel.text=@"white off";
    [self.view addSubview:whiteSetLabel];
    
    
    UIButton *Button=[UIButton buttonWithType:UIButtonTypeCustom];
    Button.frame=CGRectMake(28, 332, 36, 36);
    [Button setBackgroundImage:[UIImage imageNamed:@"暖黄"] forState:UIControlStateNormal];
    [Button addTarget:self action:@selector(SendThreeThound) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Button];
    
    UIButton *Button2=[UIButton buttonWithType:UIButtonTypeCustom];
    Button2.frame=CGRectMake(256, 332, 36, 36);
    [Button2 setBackgroundImage:[UIImage imageNamed:@"冷白"] forState:UIControlStateNormal];
    [Button2 addTarget:self action:@selector(SendSixThound) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Button2];
    
    slideImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"滑条"]];
    slideImageView.frame=CGRectMake(28, 380, 264, 24);
    [self.view addSubview:slideImageView];
    
    
    slideInImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"滑圈"]];
    slideInImage.frame=CGRectMake(28, 380, 24, 24);
    [self.view addSubview:slideInImage];
}
-(void)viewDidDisappear:(BOOL)animated{
    char strcommand[8]={'s','#','#','#','#','*','f','e'};
    strcommand[6] =5;
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:8];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
    NSLog(@"发送颜色保存");
}
-(void)SendThreeThound{
    
    valueLabel.text=@"3000";
    slideInImage.center=CGPointMake(40, 392);
    
    char strcommand[9]={'s','#','#','#','#','*','f','e'};
    
    strcommand[6] =3;
    strcommand [1] =255-255; //reg
    strcommand [2] =255-10; //green
    strcommand [3] =255-16; //blue
    strcommand [4] =255-89;  //white
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    if ([LastSendTime timeIntervalSinceNow]<-0.3) {
        LastSendTime=[[NSDate alloc]init];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
    }
}
-(void)SendSixThound{
    valueLabel.text=@"6500";
    slideInImage.center=CGPointMake(280, 392);
    
    char strcommand[9]={'s','#','#','#','#','*','f','e'};
    strcommand[6] =3;
    strcommand [1] =255-65; //reg
    strcommand [2] =255-68; //green
    strcommand [3] =255-255; //blue
    strcommand [4] =255-155;  //white
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    if ([LastSendTime timeIntervalSinceNow]<-0.3) {
        LastSendTime=[[NSDate alloc]init];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
    }
}
-(void)updateValue{
    float f = bottomSlide.value;
    valueLabel.text=[NSString stringWithFormat:@"%.0f",f];
}
-(void)viewDidAppear:(BOOL)animated{
    self.title=@"B/Color";
}
-(void)draw{
    myView.height=myView.height+10;
    [myView setNeedsDisplay];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    
    int x = point.x;
    int y = point.y;
    
    [self touchDraw:x :y];
    [self sendMessage:NO];
}

//触摸冷白暖白横条时触发事件
- (void)colorAtPixel:(CGPoint)point {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    int tempWhite   =(int)[userDefaults integerForKey:@"white"];
    
    point= CGPointMake(point.x,  12);
    
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f,0.0f, slideImageView.bounds.size.width,slideImageView.bounds.size.height), point))
    {
        return;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = slideImageView.image.CGImage;
    NSUInteger width = slideImageView.bounds.size.width;
    NSUInteger height =slideImageView.bounds.size.height;
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = {0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast |kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context,kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] /255.0f;
    CGFloat green = (CGFloat)pixelData[1] /255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] /255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] /255.0f;
    
    
    
    char strcommand[9]={'s','#','#','#','#','*','f','e'};
    
    
    strcommand[6] =3;
    strcommand [1] =255-(tempWhite*(1-alpha)+red*alpha)*255; //reg
    strcommand [2] =255-(tempWhite*(1-alpha)+green*alpha)*255; //green
    strcommand [3] =255-(tempWhite*(1-alpha)+blue*alpha)*255; //blue
    strcommand [4] =255-tempWhite;  //white
    
    
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    
    if ([LastSendTime timeIntervalSinceNow]<-0.3) {
        LastSendTime=[[NSDate alloc]init];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
    }
}

-(void)touchDraw:(int)x :(int)y{
    NSLog(@"touchDraw:%d,%d",x,y);
    if (y>340) {
        if (x<40) {
            x=40;
        }
        if (x>280) {
            x=280;
        }
        slideInImage.center=CGPointMake(x, 392);
        float seWen= (x-40)/240.0*3500+3000;
        valueLabel.text=[NSString stringWithFormat:@"%.0f",seWen];
        [self colorAtPixel:CGPointMake(x, y)];
        return;
    }
    
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
    valueLabel.text =[NSString stringWithFormat:@"%.0f%%",100*jiaoduTem/305];
    
    jiaodu=jiaoduTem;
    
    if (jiaodu<1) {
        jiaodu++;
    }
    
}

//移动外围三角触发事件
-(void)sendMessage:(BOOL)isEnd{
    
    sanjiaoView.transform=CGAffineTransformMakeRotation(3.1415926*(jiaodu-44)/180);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int tempReg;
    int tempGreen;
    int tempBlue;
    int tempWhite;
    
    tempReg     =(int)[userDefaults integerForKey:@"reg"];
    tempGreen   =(int)[userDefaults integerForKey:@"green"];
    tempBlue    =(int)[userDefaults integerForKey:@"blue"];
    tempWhite   =(int)[userDefaults integerForKey:@"white"];
    
    
    char strcommand[8]={'s','#','#','#','#','*','f','e'};
    
    if (iWhite==0) {//白光关就执行色盘颜色
        
        
        strcommand[1] =255-(int)(((tempWhite/255)*(1-jiaodu/305)+(tempReg/255.0)*jiaodu/305)*255);
        strcommand[2] =255-(int)(((tempWhite/255)*(1-jiaodu/305)+(tempGreen/255.0)*jiaodu/305)*255);
        strcommand[3] =255-(int)(((tempWhite/255)*(1-jiaodu/305)+(tempBlue/255.0)*jiaodu/305)*255);
        strcommand[4] =255;
        strcommand[6] =4;//保存
        
        myView.height=jiaodu;
        myView.red=((tempWhite/255)*(1-jiaodu/305)+(tempReg/255.0)*jiaodu/305)*255;
        myView.green=((tempWhite/255)*(1-jiaodu/305)+(tempGreen/255.0)*jiaodu/305)*255;
        myView.blue=((tempWhite/255)*(1-jiaodu/305)+(tempBlue/255.0)*jiaodu/305)*255;
        [myView setNeedsDisplay];
        
    }else{
        strcommand[1] =255;
        strcommand[2] =255;
        strcommand[3] =255;
        strcommand[4] =255-255*jiaodu/305;
        strcommand[6] =4;//保存
        
        
        myView.height=jiaodu;
        myView.red=255*jiaodu/305;
        myView.green=255*jiaodu/305;
        myView.blue=255*jiaodu/305;
        [myView setNeedsDisplay];
    }
   
    NSLog(@"发送：%f,%f",jiaodu,LastJD);
    
    if ((fabs(jiaodu-LastJD)>7&&[LastSendTime timeIntervalSinceNow]<-0.3)||isEnd) {
        LastSendTime=[[NSDate alloc]init];
        LastJD=jiaodu;
    }else{
        NSLog(@"不发送");
        return;
    }
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:8];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    
    int x = point.x;
    int y = point.y;
   
    [self touchDraw:x :y];
    [self sendMessage:NO];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    
    int x = point.x;
    int y = point.y;
   
    [self touchDraw:x :y];
    [self sendMessage:YES];
}
int regStr, greenStr, blueStr, whiteStr;


-(void)offbtClick:(UIButton*)sender
{

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    if (iWhite==0) {
        whiteSetLabel.text=@"white on";
        iWhite=255; //白光开
        myView.height=jiaodu;
        myView.red=255*jiaodu/305;
        myView.green=255*jiaodu/305;
        myView.blue=255*jiaodu/305;
        [myView setNeedsDisplay];
        
    }else{
        whiteSetLabel.text=@"white off";
        iWhite=0;   //白光关
        int tempReg     =(int)[userDefaults integerForKey:@"reg"];
        int tempGreen   =(int)[userDefaults integerForKey:@"green"];
        int tempBlue    =(int)[userDefaults integerForKey:@"blue"];
        myView.red=(tempReg/255.0)*jiaodu/305*255;
        myView.green=(tempGreen/255.0)*jiaodu/305*255;
        myView.blue=(tempBlue/255.0)*jiaodu/305*255;
        [myView setNeedsDisplay];
    }
    [userDefaults setInteger:iWhite forKey:@"white"];
}

//转动中心圆时触发此委托
-(void)colorDidChange:(EFCircularSlider*)slider {
    if (iWhite==255) {//白光开时不响应中心圆
        myView.height=jiaodu;
        myView.red=255*jiaodu/305;
        myView.green=255*jiaodu/305;
        myView.blue=255*jiaodu/305;
        [myView setNeedsDisplay];
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    char strcommand[9]={'s','#','#','#','#','*','f','e'};
    strcommand[6] =3;
    int newVal = (int)slider.currentValue < 360 ? (int)slider.currentValue : 0;
    NSLog(@"----------------%d",newVal);
    
    if (0<=newVal&&newVal<=45) {
        iReg=255,igreen=0;
        iBlue=newVal*255/45;        //0度到45度，蓝色的值改变
    }
    if (45<=newVal&&newVal<=135) {
        iReg=255-(newVal-45)*255/90;  //45度到135度，红色的值改变
    }
    if (135<=newVal&&newVal<=180) {
        iReg=0,iBlue=255;
        igreen=(newVal-135)*255/45;                         //135度到180度，绿色的值改变
    }
    if (180<=newVal&&newVal<=225) {
        iReg=0,igreen=255;
        iBlue=255-(newVal-180)*255/45;                         //180度到225度，蓝色的值改变
    }
    if (225<=newVal&&newVal<=315) {
        iBlue=0,igreen=255;
        iReg=(newVal-225)*255/90;                               //225度到315度，红色的值改变
    }
    if (315<=newVal&&newVal<=360)
    {
        iReg=255,iBlue=0;
        igreen=255-(newVal-315)*255/45;                         //315度到360度，绿色的值改变
    }
    strcommand [1] =255-iReg*jiaodu/305;
    strcommand [2] =255-igreen*jiaodu/305;
    strcommand [3] =255-iBlue*jiaodu/305;
    strcommand [4] =255-iWhite*jiaodu/305;
    
    myView.height=jiaodu;
    myView.red=iReg*jiaodu/305;
    myView.green=igreen*jiaodu/305;
    myView.blue=iBlue*jiaodu/305;
    [myView setNeedsDisplay];
    
   
    //保存当前的rgb的值
    [userDefaults setInteger:iReg forKey:@"reg"];
    [userDefaults setInteger:igreen forKey:@"green"];
    [userDefaults setInteger:iBlue forKey:@"blue"];
    
    
    if ([LastSendTime timeIntervalSinceNow]<-0.3) {
        LastSendTime=[[NSDate alloc]init];
    }else{
        return;
    }

    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
}



@end

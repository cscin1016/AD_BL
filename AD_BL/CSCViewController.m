//
//  CSCViewController.m
//  imageOperating
//
//  Created by apple on 14-6-11.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//
#define MAX_NUMBER_LIGHT 10
#define HEIGHT 60
#define WIGHT 30

#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreGraphics/CoreGraphics.h>


#import "CSCViewController.h"
#import "AppDelegate.h"

@interface CSCViewController (){
    
    int numberOfLight;//当前连接了多少个灯
    int selectLightMove;//选中某个圈进行移动。-1表示未选中,0-9表示移动的哪个灯
    
    UIImageView *ColorView[MAX_NUMBER_LIGHT];//10个圈
    CGRect mPieRect[MAX_NUMBER_LIGHT];//每个圈的坐标
    
    NSDate *LastSendTime;
    
//    UIView *testView[MAX_NUMBER_LIGHT];
    UIView *testPoint;
}

@end

@implementation CSCViewController

//显示相册库进行选择图片
-(void)showImagePicker
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    //调用系统照片库
}

#pragma - mark delegate methods
//选择完成之后
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    NSLog(@"editingInfo:%@",editingInfo);
    //改背景图为选择的图片
    self.selectedImage.image = image;
    
   
    [self dismissModalViewControllerAnimated:YES];
}

#pragma - mark delegate methods
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //取消选择图片
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    selectLightMove=-1;//设置当前能移动的灯泡为未选中
    
    LastSendTime= [[NSDate alloc]init];
	
    //默认一张背景图片
    self.selectedImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64-10)];
    self.selectedImage.image=[UIImage imageNamed:[NSString stringWithFormat:@"11.jpg"]];
    [self.view addSubview:self.selectedImage];
    
    self.title=@"ImageMode";
    
    //设置10个默认感应区域
    CGPoint point;
    for (int i = 0; i < MAX_NUMBER_LIGHT; i++){
        point.x = 80+(HEIGHT/2+20)*(i%5);
		point.y = 80+(HEIGHT/2+40)*(i/5);
        mPieRect[i] =CGRectMake (point.x - WIGHT, point.y - HEIGHT, WIGHT, HEIGHT);
        
        ColorView[i] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imageMode3.png"]];
        ColorView[i].frame =mPieRect[i];
        ColorView[i].backgroundColor=[UIColor clearColor];
        ColorView[i].hidden=NO;
        ColorView[i].userInteractionEnabled=NO;
        
        testPoint=[[UIView alloc]init];
        testPoint.frame=CGRectMake(-5, 0, 5, 5);
        testPoint.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:testPoint];
        
        [self.view addSubview:ColorView[i]];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    if (IS_IOS_7) {
        UIBarButtonItem *myAddButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showImagePicker)];
        myAddButton.tintColor=[UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = myAddButton;
    }else {
        UIButton *btnRight=[UIButton buttonWithType:UIButtonTypeCustom];
        btnRight.frame=CGRectMake(0, 0, 24, 24);
        [btnRight setBackgroundImage:[UIImage imageNamed:@"add4"] forState:UIControlStateNormal];
        [btnRight addTarget:self action:@selector(showImagePicker) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btnRight];
    }
    
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    numberOfLight=(int)[userDefaults integerForKey:@"numberOfLight"];
   
    for (int i=0; i<10; i++) {
        if (i<numberOfLight) {
            ColorView[i].hidden=NO;
        }else{
            ColorView[i].hidden=YES;
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint touched=[[[touches allObjects] objectAtIndex:0] locationInView:self.view];
    for (int i=0; i<numberOfLight; i++) {
        if (CGRectContainsPoint (mPieRect[i], touched)){
            selectLightMove=i;
            break;
        }
    }
    if (selectLightMove>=0) {//如果有选中，则改变背景图
        self.view.backgroundColor=[self colorAtPixel:CGPointMake(touched.x+WIGHT, touched.y+HEIGHT)];
        
        [ColorView[selectLightMove] setImage:[UIImage imageNamed:@"imageMode4.png"]];
        //视图中心
        ColorView[selectLightMove].center=CGPointMake(touched.x-WIGHT*0.5, touched.y+HEIGHT*0.25);
        //感应区域
        mPieRect[selectLightMove]=CGRectMake(touched.x-WIGHT*1.5, touched.y-HEIGHT*0.25, HEIGHT, HEIGHT);
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint touched=[[[touches allObjects] objectAtIndex:0] locationInView:self.view];
    if (selectLightMove>=0) {
        self.view.backgroundColor=[self colorAtPixel:CGPointMake(touched.x-WIGHT*0.5, touched.y+HEIGHT*0.75)];
        
        
        //视图中心
        ColorView[selectLightMove].center=CGPointMake(touched.x-WIGHT*0.5, touched.y+HEIGHT*0.25);
        //感应区域
        mPieRect[selectLightMove]=CGRectMake(touched.x-WIGHT*1.5, touched.y-HEIGHT*0.25, HEIGHT, HEIGHT);
        testPoint.center=CGPointMake(touched.x-WIGHT*0.5, touched.y+HEIGHT*0.75);
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (selectLightMove>=0) {
        [ColorView[selectLightMove] setImage:[UIImage imageNamed:@"imageMode3.png"]];
//        ColorView[selectLightMove].backgroundColor=[UIColor clearColor];
    }
    selectLightMove=-1;
}

- (UIColor *)colorAtPixel:(CGPoint)point {
    if (self.selectedImage.image.imageOrientation==UIImageOrientationRight) {
        NSLog(@"UIImageOrientationRight-----");
//        CGContextRotateCTM(context, M_PI_4/4);
        float rate=self.selectedImage.frame.size.height/self.selectedImage.frame.size.width;
        point= CGPointMake(self.selectedImage.frame.size.width-(self.selectedImage.frame.size.height- point.y)/rate,self.selectedImage.frame.size.height-point.x*rate);
    }else if(self.selectedImage.image.imageOrientation==UIImageOrientationLeft){
        NSLog(@"UIImageOrientationLeft------");
        float rate=self.selectedImage.frame.size.height/self.selectedImage.frame.size.width;
        point= CGPointMake((self.selectedImage.frame.size.height- point.y)/rate,point.x*rate);
    }else if(self.selectedImage.image.imageOrientation==UIImageOrientationDown){
        NSLog(@"UIImageOrientationDown------");
        point= CGPointMake(self.selectedImage.frame.size.width-point.x, self.selectedImage.frame.size.height-point.y);
    }else if(self.selectedImage.image.imageOrientation==UIImageOrientationUp){
        NSLog(@"UIImageOrientationUp-------");
        point= CGPointMake(point.x,  point.y);
    }else{
        NSLog(@"未知方向-----");
        point= CGPointMake(point.x,  point.y);
    }
    
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f,0.0f, self.selectedImage.bounds.size.width,self.selectedImage.bounds.size.height), point)) {
        NSLog(@"不在区域");
        return nil;
    }
    
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    NSLog(@"point:%ld,%ld",(long)pointX,(long)pointY);
    CGImageRef cgImage = self.selectedImage.image.CGImage;
    NSUInteger width = self.selectedImage.bounds.size.width;
    NSUInteger height =self.selectedImage.bounds.size.height;
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
    NSLog(@"R:%.0f,G:%.0f,B:%.0f,A:%.0f",(CGFloat)pixelData[0],(CGFloat)pixelData[1],(CGFloat)pixelData[2],alpha);
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    int tempWhite   =(int)[userDefaults integerForKey:@"white"];
    
    char strcommand[9]={'s','#','#','#','#','*','f','e'};
    
    
    strcommand[6] =3;
    strcommand [1] =255-(tempWhite*(1-alpha)+red*alpha)*255; //reg
    strcommand [2] =255-(tempWhite*(1-alpha)+green*alpha)*255; //green
    strcommand [3] =255-(tempWhite*(1-alpha)+blue*alpha)*255; //blue
    strcommand [4] =255-tempWhite;  //white
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",[NSNumber numberWithInt:selectLightMove],@"selectLightMove",nil];
    
    if ([LastSendTime timeIntervalSinceNow]<-0.3) {
        LastSendTime=[[NSDate alloc]init];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


//CGImageSourceRef是整个imageIO的入口，通过它我们可以完成从文件的加载图片。加载完成以后我们就得到一个CGImageSourceRef，通过CGImageSourceRef我们就可以获取图片文件的大小，UTI(uniform type identifier)，内部包含几张图片，访问每一张图片以及获取每张图片对应的exif信息等。
//imageSourceRef和文件是一一对应的，通常我们见到的图片文件(例如jpg，png)内部都只有一张图片，这种情况我们通过CGImageSourceGetCount方法得到的就会是1。但是不能排除一个图片文件中会有多种图片的情况，例如gif文件，这个时候一个文件中就可能包含几张甚至几十张图片。
@end

//
//  RecordVC.m
//  ADM_Lights
//
//  Created by admin on 14-3-5.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import "RecordVC.h"
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

//版本号
#define DeviceVision [[[UIDevice currentDevice] systemVersion] floatValue]

@interface RecordVC (){
    NSDate *LastSendTime;
}

@end

@implementation RecordVC
@synthesize progressView,theimageView,shapeLayer,displayLink,loopCount;
@synthesize pv1;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    self.title=@"Voice Mode";
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	LastSendTime= [[NSDate alloc]init];
    //背景图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"app_bg"];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    
    
    //录音图像
    
    UIImage *recodeImage = [UIImage imageNamed:@"record"];
    
    UIImageView *recodeImageView  = [[UIImageView alloc] initWithImage:recodeImage];
    
    recodeImageView.frame =CGRectMake(0,[UIScreen mainScreen].bounds.size.height-64-recodeImage.size.height,  self.view.bounds.size.width, recodeImage.size.height);
    recodeImageView.userInteractionEnabled = YES;
    [self.view addSubview:recodeImageView];
    
    
    //最小最大按钮
    
    UIImage *minImage = [UIImage imageNamed:@"record_min"];
    
    UIImageView *minImageView  = [[UIImageView alloc] initWithImage:minImage];
    
    minImageView.frame =CGRectMake(20,[UIScreen mainScreen].bounds.size.height-64-minImage.size.height-60, minImage.size.width, minImage.size.height);
    minImageView.userInteractionEnabled = YES;
    [self.view addSubview:minImageView];
    
    UIImage *maxImage = [UIImage imageNamed:@"record_max"];
    
    UIImageView *maxImageView  = [[UIImageView alloc] initWithImage:maxImage];
    
    maxImageView.frame =CGRectMake(270,[UIScreen mainScreen].bounds.size.height-64-maxImage.size.height-65, maxImage.size.width+5, maxImage.size.height+5);
    maxImageView.userInteractionEnabled = YES;
    [self.view addSubview:maxImageView];
   

    
    
    //录音按钮
    
    UIImage *btView = [UIImage imageNamed:@"record_off"];
    UIImage *btViewDown = [UIImage imageNamed:@"record_on"];
    
    NSLog(@"height==%f--width==%f",btView.size.height,btView.size.width);
    
    recordButton =[UIButton buttonWithType:UIButtonTypeCustom];
    recordButton.frame =CGRectMake(320/2-btView.size.width/2, [UIScreen mainScreen].bounds.size.height-64-btView.size.height, btView.size.width, btView.size.height);
    [recordButton setImage:btView forState:UIControlStateNormal];
    [recordButton setImage:btViewDown forState:UIControlStateSelected];
    recordButton.selected=NO;
    
    [recordButton addTarget:self action:@selector(isRecord:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:recordButton];
    
    
    //音调长短，圆形进度条
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    
    
    progressView.frame =CGRectMake(0, [UIScreen mainScreen].bounds.size.height-64-btView.size.height-20, 320, 40);
    progressView.progress=0;
    [self.view addSubview:progressView];
    
    
//    pv1 = [[AMProgressView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-64-btView.size.height-20, 320, 25)
//                              andGradientColors:[NSArray arrayWithObjects:[UIColor blueColor], nil]
//                               andOutsideBorder:NO
//                                    andVertical:NO];
//    // Display
//    pv1.emptyPartAlpha = 1.0f;
//    pv1.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:pv1];

    
    
    //playBUtton
    UIButton * play =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    play.frame =CGRectMake(220, 340, 60, 30);
    //    connectBt.titleLabel=@"connect";
    [ play setTitle:@"play" forState:UIControlStateNormal];
     [ play setTitle:@"playstop" forState:UIControlStateSelected];
    play.selected=NO;
    
    play.tintColor=[UIColor whiteColor];
    [play addTarget:self action:@selector(paly:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:play];
//    [play release];

    

    
    
     
}
-(void)paly:(UIButton*)sender
{
if(sender.selected==YES){
    sender.selected=NO;
    
    
    [self stopPlaying];
    
    
}else{
    sender.selected=YES;
    
    [self playClick];
    
}
}

-(void)stopPlaying
{
    NSLog(@"stopPlaying");
    [audioPlayer stop];
    NSLog(@"stopped");
    
}



-(void)playClick
{
    NSLog(@"playRecording");
    // Init audio with playback capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(
                                                            NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"recordTest.caf"];
    
    NSURL *url = [NSURL fileURLWithPath:soundFilePath];
    
    // NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/recordTest.caf", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 0;
    [audioPlayer play];
    NSLog(@"playing");
    
}
//录音事件
-(void)isRecord:(UIButton*)sender
{
    if(sender.selected==YES){
        sender.selected=NO;
        [self stopRecording];
        
        
    }else{
        sender.selected=YES;
        
         [self startRecording];
        
    }

}



-(void)startRecording
{
    audioRecorder = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    
    /////////////同时能播放音乐
    UInt32 category = kAudioSessionCategory_PlayAndRecord;
    
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    ///////////
    UInt32 mix_override = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof (mix_override), &mix_override);
    //////////
    
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof (audioRouteOverride),&audioRouteOverride);
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
    if(recordEncoding == ENC_PCM)
    {
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    }
    else
    {
        NSNumber *formatObject;
        
        switch (recordEncoding) {
            case (ENC_AAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
                break;
            case (ENC_ALAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
                break;
            case (ENC_IMA4):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
                break;
            case (ENC_ILBC):
                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
                break;
            case (ENC_ULAW):
                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
                break;
            default:
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
        }
        
        [recordSettings setObject:formatObject forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    }
    
    //    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/recordTest.caf", [[NSBundle mainBundle] resourcePath]]];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(
                                                            NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"recordTest.caf"];
    
    NSURL *url = [NSURL fileURLWithPath:soundFilePath];
    
    
    NSError *error = nil;
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    audioRecorder.meteringEnabled = YES;
    if ([audioRecorder prepareToRecord] == YES){
        audioRecorder.meteringEnabled = YES;
        [audioRecorder record];
        timerForPitch =[NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    }else {
        int errorCode = CFSwapInt32HostToBig ((int)[error code]);
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
        
    }
    
  

}

- (void)levelTimerCallback:(NSTimer *)timer {
	[audioRecorder updateMeters];
	
    
    //音量的最大值
    float linear = pow (10, [audioRecorder peakPowerForChannel:0]/20 );
    if (linear<0.06) {
        return;
    }
    
    //获取音量的平均值
    float linear1 = pow (10, [audioRecorder averagePowerForChannel:0]/20 );
    NSLog(@"音量的平均值:%f",linear1);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (linear1>0.03) {
        
        Pitch = linear1+.20;
            
        int tempReg     =(int)[userDefaults integerForKey:@"reg"];
        int tempGreen   =(int)[userDefaults integerForKey:@"green"];
        int tempBlue    =(int)[userDefaults integerForKey:@"blue"];
        int tempWhite   =(int)[userDefaults integerForKey:@"white"];
        
    
        int iReg,igreen,iBlue,iWhite;
       
        iReg =linear1*tempReg;
        igreen  =linear1*tempGreen;
        iBlue =linear1*tempBlue;
        iWhite =linear1*tempWhite;
        
        
        
        char strcommand[8]={'s','r','g','b','w','*','#','e'};
        strcommand [1] =255-iReg;
        strcommand [2] =255-igreen;
        strcommand [3] =255-iBlue;
        strcommand [4] =255-iWhite;
        strcommand[6] =3;
        
        if ([LastSendTime timeIntervalSinceNow]<-0.30) {
            LastSendTime=[[NSDate alloc]init];
        }else{
            return;
        }
        NSData *cmdData = [NSData dataWithBytes:strcommand length:8];
        NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
        
    }else{
        Pitch=0;
    }
    
    
    [progressView setProgress:Pitch];
    
    
}
-(void)stopRecording
{
    [audioRecorder stop];
//    self.shapeLayer.path = [[self pathAtInterval:0] CGPath];
    [timerForPitch invalidate];
    timerForPitch = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self stopRecording];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self stopRecording];
    
}
-(void)back
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  musicModle.m
//  InlLit
//
//  Created by apple on 14-7-11.
//  Copyright (c) 2014年 com.aidian. All rights reserved.
//

#import "musicModle.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoViewController.h"

#define OURMAX	30.0f

@interface musicModle ()<AVAudioPlayerDelegate>{
    AVAudioPlayer *player;
    NSTimer *timer;
    BOOL musicModeID;
    float pinglv;
    float bilvValue;
    
    VideoViewController *videoView;
    NSURL *urlOfSong;
    
    NSMutableArray *MP3Arr;
}

@end

@implementation musicModle
@synthesize maxProgress,aveProgress,volumeSlider,progressSlider;
@synthesize currentTime,allTime;

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
    // Do any additional setup after loading the view.
    
    pinglv=0.25;
    bilvValue=40;
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(update:) name:@"update" object:nil];
}
- (NSString *) formatTime: (int) num
{
	int secs = num % 60;
	int min = num / 60;
	if (num < 60) return [NSString stringWithFormat:@"0:%02d", num];
	return	[NSString stringWithFormat:@"%d:%02d", min, secs];
}
- (void) updateMeters
{
	[player updateMeters]; //更新进度
	float avg = -1.0f * [player averagePowerForChannel:0];//平均振幅
	float peak = -1.0f * [player peakPowerForChannel:0];//最高振幅
    NSLog(@"%f,%f",avg,peak);
	aveProgress.progress = (OURMAX - avg) / OURMAX;
	maxProgress.progress = (OURMAX - peak) / OURMAX;
    
    currentTime.text=[self formatTime:player.currentTime];
    allTime.text=[self formatTime:player.duration];
    
    progressSlider.value = (player.currentTime / player.duration);
    
    
    
    int iReg=0,igreen=0,iBlue=0,iWhite=0;
    
    if (!musicModeID) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        int tempReg;
        int tempGreen;
        int tempBlue;
        int tempWhite;
        tempReg     =(int)[userDefaults integerForKey:@"reg"];
        tempGreen   =(int)[userDefaults integerForKey:@"green"];
        tempBlue    =(int)[userDefaults integerForKey:@"blue"];
        tempWhite   =(int)[userDefaults integerForKey:@"white"];
        
        
        iReg    =   (avg*tempReg/255)*bilvValue;
        igreen  =   (avg*tempGreen/255)*bilvValue;
        iBlue   =   (avg*tempBlue/255)*bilvValue;
        iWhite  =   (avg*tempBlue/255)*bilvValue;
        if(iReg>255)iReg=255;
        if(igreen>255)igreen=255;
        if(iBlue>255)iBlue=255;
        if(iWhite>254)iWhite=254;
        NSLog(@"%d,%d,%d,%d",iReg,igreen,iBlue,iWhite);
    }
    

    
    char strcommand[9]={'s','#','#','#','#','*','f','e'};
    strcommand[6] =3;
    strcommand [1] =255-iReg;
    strcommand [2] =255-igreen;
    strcommand [3] =255-iBlue;
    strcommand [4] =255-iWhite;
    NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
    
}
- (IBAction)colorOrBright:(id)sender {
    
}

- (IBAction)playAction:(id)sender {
    NSError *error;
    if (urlOfSong) {
        player=[[AVAudioPlayer alloc]initWithContentsOfURL:urlOfSong error:&error];
        NSLog(@"获取到URl");
    }else{
        NSString *path= [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return ;
        player=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:path] error:&error];
    }
    
    if (!player) {
        return;
    }
    
    [player prepareToPlay];
    [player setNumberOfLoops:2];
    player.meteringEnabled = YES;
    player.delegate = self;
    
    if (!player) {
        NSLog(@"播放器发生错误");
        return;
    }
    [player play]; //播放音乐
    volumeSlider.value = player.volume;
    NSLog(@"player.volume:%f",player.volume);
    volumeSlider.enabled=YES;
    timer=[NSTimer scheduledTimerWithTimeInterval:0.25f  target:self  selector:@selector(updateMeters) userInfo:nil repeats:YES];
    progressSlider.enabled=YES;
}
- (IBAction)pauseAction:(id)sender {
    [timer invalidate];
    [player pause]; //暂停播放
    
    maxProgress=0;
    aveProgress=0;
    volumeSlider.enabled=NO;
    progressSlider.enabled=NO;
    
}
- (IBAction)stopAction:(id)sender {
    [timer invalidate];
    if(player.playing){
        [player stop]; //停止播放
    }
}

- (IBAction)pinglv:(id)sender {
    [self pauseAction:nil];
    NSInteger Index =((UISegmentedControl *)sender).selectedSegmentIndex;
    switch (Index) {
        case 0:
            pinglv=0.15;
            break;
        case 1:
            pinglv=0.2;
            break;
        case 2:
            pinglv=0.25;
            break;
        case 3:
            pinglv=0.3;
        default:
            break;
    }
    [self playAction:nil];
}

- (IBAction)bilv:(id)sender {
    NSInteger Index =((UISegmentedControl *)sender).selectedSegmentIndex;
    switch (Index) {
        case 0:
            bilvValue=20;
            break;
        case 1:
            bilvValue=40;
            break;
        case 2:
            bilvValue=60;
            break;
        case 3:
            bilvValue=80;
        default:
            break;
    }
}

- (IBAction)progressChanged:(id)sender {
    player.currentTime = progressSlider.value * player.duration;
}

- (IBAction)volumeChanged:(id)sender {
    player.volume = volumeSlider.value;
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"播放完毕");
    [timer invalidate];
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"error:%@",error);
}
//歌曲列表
-(IBAction)addList:(id)sender
{
    NSLog(@"///////////////////////////");
    videoView=[[VideoViewController alloc]init];
    [self.navigationController pushViewController:videoView animated:YES];
    
}

-(void)update:(NSNotification*) notification{
    
    NSURL *num = [[notification userInfo] objectForKey:@"the"];
    urlOfSong=num;
    NSLog(@"%@,%@",[notification userInfo],num);
}

@end

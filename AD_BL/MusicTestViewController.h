//
//  MusicTestViewController.h
//  ADM_Lights
//
//  Created by admin on 14-4-19.
//  Copyright (c) 2014年 admin. All rights reserved.
//


#import "EZAudio.h"

@interface MusicTestViewController : UIViewController<EZAudioFileDelegate,EZOutputDataSource>
// EZAudioFile 表示当前选定的音频文件
@property (nonatomic,strong) EZAudioFile *audioFile;
@property (retain, nonatomic) IBOutlet UIButton *musicList;

@property (nonatomic,strong) IBOutlet UILabel *filePathLabel;

@property (nonatomic,strong) IBOutlet UISlider *framePositionSlider;
@property (nonatomic,strong) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *musicModeID;

//指示是否已经到达文件的末尾
@property (nonatomic,assign) BOOL eof;

-(IBAction)addList:(id)sender;

-(IBAction)play:(id)sender;

-(IBAction)nextPlay:(id)sender;
-(IBAction)beforePlay:(id)sender;


-(IBAction)seekToFrame:(id)sender;
- (IBAction)musicModeAction:(id)sender;

@end

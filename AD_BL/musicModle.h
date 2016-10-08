//
//  musicModle.h
//  InlLit
//
//  Created by apple on 14-7-11.
//  Copyright (c) 2014年 com.aidian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface musicModle : UIViewController

@property (weak, nonatomic) IBOutlet UIProgressView *maxProgress;
@property (weak, nonatomic) IBOutlet UIProgressView *aveProgress;

@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *allTime;

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
- (IBAction)colorOrBright:(id)sender;
- (IBAction)pinglv:(id)sender;
- (IBAction)bilv:(id)sender;

- (IBAction)playAction:(id)sender;
- (IBAction)pauseAction:(id)sender;
- (IBAction)stopAction:(id)sender;

- (IBAction)progressChanged:(id)sender;
- (IBAction)volumeChanged:(id)sender;

-(IBAction)addList:(id)sender;
@end

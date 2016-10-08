//
//  HNHHEQVisualizer.m
//  HNHH
//
//  Created by Dobango on 9/17/13.
//  Copyright (c) 2013 RC. All rights reserved.
//

#import "PCSEQVisualizer.h"
#import "UIImage+Color.h"


#define kWidth 8
#define kHeight 80
#define kPadding 4
static   int mm = 0;    //标记柱子轮到那个柱子涨高低

#define  MUSICRATE 0.1
#define  MUSICRATESECOND 0.3
#define  MUSICRATETHRID 0.5

#define  LAYENUMBER 10

@implementation PCSEQVisualizer
{
    NSTimer* timer;
    NSArray* barArray;
    NSNumber*hing;
    NSDate *LastSendTime;
    
    
    int oldMusicNumber;
    int oldOneMusicNumber;
    int oldTwoMusicNumber;
    int oldThreeMusicNumber;
    int oldFourMusicNumber;
    
    int  oldSectNumber;
    int  newSectNumber;
    int  whoNumber;
    
}
@synthesize delegate;
@synthesize musicModeID;
- (id)initWithNumberOfBars:(int)numberOfBars
{
    self = [super init];
    if (self) {
        LastSendTime= [[NSDate alloc]init];
        hing = [[NSNumber alloc]init];
        self.frame = CGRectMake(0, 0, kPadding*numberOfBars+(kWidth*numberOfBars), kHeight);
        
        NSMutableArray* tempBarArray = [[NSMutableArray alloc]initWithCapacity:numberOfBars];
        
        for(int i=0;i<numberOfBars;i++){
            
            UIImageView* bar = [[UIImageView alloc]initWithFrame:CGRectMake(i*kWidth+i*kPadding, 0, kWidth, 1)];
            bar.image = [UIImage imageWithColor:self.barColor];
            [self addSubview:bar];
            [tempBarArray addObject:bar];
            
            
        }

        barArray = [[NSArray alloc]initWithArray:tempBarArray];
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2*2);
        self.transform = transform;
       
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:@"stopTimer" object:nil];
  
    }
    return self;
}


-(void)start{
    
    self.hidden = NO;
}


-(void)stop{
    [timer invalidate];
    timer = nil;
}

-(void)sethight:(NSNumber*)hin{
    
    hing = hin;
    [UIView animateWithDuration:.3 animations:^{
        if (mm< [barArray count]) {
            UIImageView* bar = [barArray objectAtIndex:mm];
            CGRect rect = bar.frame;
            rect.origin.y =0;
            CGFloat hh = [hing floatValue];
            hh = fabs(hh);
            rect.size.height = hh*100; //0 -
            bar.frame = rect;
            mm++;
            
            int iReg=0,igreen=0,iBlue=0,iWhite=0;
            
            if (musicModeID) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                int tempReg;
                int tempGreen;
                int tempBlue;
                int tempWhite;
                tempReg     =(int)[userDefaults integerForKey:@"reg"];
                tempGreen   =(int)[userDefaults integerForKey:@"green"];
                tempBlue    =(int)[userDefaults integerForKey:@"blue"];
                tempWhite   =(int)[userDefaults integerForKey:@"white"];
                
                
                iReg    =   (rect.size.height*tempReg/255)*4;
                igreen  =   (rect.size.height*tempGreen/255)*4;
                iBlue   =   (rect.size.height*tempBlue/255)*4;
                iWhite  =   (rect.size.height*tempWhite/255)*4;

            }else{
                
                
                switch (whoNumber) {
                    case 0:
                        oldMusicNumber=rect.size.height;
                        break;
                    case 1:
                        oldOneMusicNumber=rect.size.height;
                        break;
                    case 2:
                        oldTwoMusicNumber=rect.size.height;
                        break;
                    case 3:
                        oldThreeMusicNumber=rect.size.height;
                        break;
                    case 4:
                        oldFourMusicNumber=rect.size.height;
                        break;
                    default:
                        break;
                }
                whoNumber++;
                if (whoNumber<4) {
                    return;
                }else{
                    whoNumber=0;
                }
                
                newSectNumber=(oldThreeMusicNumber+oldTwoMusicNumber+oldOneMusicNumber+oldMusicNumber)/4;
                NSLog(@"%d",newSectNumber);
                
                if (newSectNumber>oldSectNumber) {
                    NSLog(@"最大:%d",newSectNumber);
                    oldSectNumber=newSectNumber;
                }
                
                switch ([self levelChange:newSectNumber])
                {
                    case 0:
                        iBlue   =   2+newSectNumber/2;
                        iReg    =   newSectNumber/3;
                        break;
                    case 1:
                        // iBlue   =   255.0*MUSICRATE*newSectNumber/LAYENUMBER+2;
                        iReg   = newSectNumber/2;
                        igreen  = 10*(newSectNumber-10)/LAYENUMBER;
                        break;
                    case 2:
//                    iBlue   =   255.0*MUSICRATE*2*(2*LAYENUMBER-newSectNumber)/LAYENUMBER;
//                    igreen  =   255.0*MUSICRATE*2*(newSectNumber-LAYENUMBER)/LAYENUMBER;
                        iBlue=15;
                        igreen=15;
                        break;
                    case 3:
                        //                            igreen  =   255.0*MUSICRATE*2*(LAYENUMBER*3-newSectNumber)/LAYENUMBER+10;
                        igreen=20;
                        break;
                    case 4:
                        igreen  =   255.0*MUSICRATE*5*(newSectNumber-LAYENUMBER*3)/LAYENUMBER+20;
                        iReg    =   255.0*MUSICRATE*5*(LAYENUMBER*4-newSectNumber)/LAYENUMBER+20;
                        //                            igreen=25;
                        //                            iReg=30;
                        break;
                    case 5:
                        iReg    =   255.0*MUSICRATE*5*(LAYENUMBER*5-newSectNumber)/LAYENUMBER+40;
                        break;
                    case 6:
                        iReg    =   255.0*MUSICRATE*5*(newSectNumber-LAYENUMBER*5)/LAYENUMBER;
                        if(iReg>255){
                            iReg=255;
                            iWhite=255;
                        }
                        break;
                    default:
                        break;
                }
            }
            
            char strcommand[8]={'s','r','g','b','w','*','f','e'};
            strcommand[6] =3;
            strcommand [1] =255-iReg;
            strcommand [2] =255-igreen;
            strcommand [3] =255-iBlue;
            strcommand [4] =255-iWhite;
            NSData *cmdData = [NSData dataWithBytes:strcommand length:8];
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];

        }else{
            mm=0;
            UIImageView* bar = [barArray objectAtIndex:mm];
            CGRect rect = bar.frame;
            rect.origin.y =0;
            CGFloat hh = [hing floatValue];
            hh = fabs(hh);
            rect.size.height = hh*130;
            bar.frame = rect;
            mm++;
            
        }
    }];
}

-(int)levelChange:(int)musicNumber{
    if (musicNumber>LAYENUMBER*5) {
        return 6;
    }else{
        return musicNumber/LAYENUMBER;
    }
}

-(void)ticker{

    [UIView animateWithDuration:.35 animations:^{
        
        for(UIImageView* bar in barArray){
            CGRect rect = bar.frame;
            rect.origin.y = 0;
            rect.size.height = arc4random() % kHeight + 1;
//            NSLog(@"%f",rect.size.height);
            //            rect.size.height = [hing floatValue]*10;
            bar.frame = rect;
            
            
        }
    
    }];
}

@end

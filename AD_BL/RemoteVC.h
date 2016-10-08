//
//  RemoteVC.h
//  ADM_Lights
//
//  Created by admin on 14-3-5.
//  Copyright (c) 2014年 admin. All rights reserved.
//


#define isiPhone4 ( [UIScreen mainScreen].bounds.size.height == 480 )

#import <UIKit/UIKit.h>

@interface RemoteVC : UIViewController

-(void)createButton;
-(void)addButtonClick;
@end

//
//  BrignessVC.h
//  ADM_Lights
//
//  Created by admin on 14-3-7.
//  Copyright (c) 2014年 admin. All rights reserved.
//


#import "draw_graphic.h"



@protocol ColorVCDelegate <NSObject>

-(void)colorDidChange:(UIColor*)color;

@end

@interface BrignessVC : UIViewController
{
	
    id <ColorVCDelegate> delegate;
    
}
@property (assign,nonatomic) id <ColorVCDelegate> delegate;
@end

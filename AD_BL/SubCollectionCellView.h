//
//  SubCollectionCellView.h
//  TestZJMuseumIpad
//
//  Created by 胡 jojo on 13-10-11.
//  Copyright (c) 2013年 tracy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubCollectionCellView : UIView
{

    UIImageView *_iconImageView;
    
    UILabel *_niandaiLabel;

    UILabel *_titleLabel;
    
    UILabel *_nameLabel;
    
    UILabel *_contentLabel;
}

@property(retain,nonatomic) UIImageView *iconImageView;
@property(retain,nonatomic) UILabel *niandaiLabel;
@property(retain,nonatomic) UILabel *titleLabel;
@property(retain,nonatomic) UILabel *nameLabel;
@property(retain,nonatomic) UILabel *contentLabel;

-(void) initUI;

@end

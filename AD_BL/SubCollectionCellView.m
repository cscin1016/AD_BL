//
//  SubCollectionCellView.m
//  TestZJMuseumIpad
//
//  Created by 胡 jojo on 13-10-11.
//  Copyright (c) 2013年 tracy. All rights reserved.
//

#import "SubCollectionCellView.h"

@implementation SubCollectionCellView

@synthesize iconImageView=_iconImageView;
@synthesize niandaiLabel=_niandaiLabel;
@synthesize titleLabel=_titleLabel;
@synthesize nameLabel=_nameLabel;
@synthesize contentLabel=_contentLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

-(void) initUI
{
    self.userInteractionEnabled=YES;
    self.backgroundColor=[UIColor clearColor];
    //圆圈亮度条
    _iconImageView=[[UIImageView alloc] init];
    [_iconImageView setFrame:CGRectMake(10, self.frame.size.height/2-140/2, 140, 140)];

    [self addSubview:_iconImageView];

    //亮度值
     _niandaiLabel=[[UILabel alloc] init];
     [_niandaiLabel setFrame:CGRectMake(_iconImageView.frame.size.width/2-40,20,50,30)];
    [_niandaiLabel setBackgroundColor:[UIColor clearColor]];
    [_niandaiLabel setTextColor:[UIColor colorWithRed:0.0 green:0.9 blue:0.9 alpha:1.0]];
    [_niandaiLabel setFont:[UIFont fontWithName:@"Helvetica" size:28]];
    [_niandaiLabel setTextAlignment:NSTextAlignmentRight];
    [_iconImageView addSubview:_niandaiLabel];
    
    // 百分值
     _titleLabel=[[UILabel alloc] init];
    [_titleLabel setFrame:CGRectMake(80, 30, 20, 20)];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setTextColor:[UIColor colorWithRed:0.0 green:0.9 blue:0.9 alpha:1.0]];
    [_titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_iconImageView addSubview:_titleLabel];
    
    // name
    _nameLabel=[[UILabel alloc] init];
    [_nameLabel setFrame:CGRectMake(30,_titleLabel.frame.origin.y+_titleLabel.frame.size.height+40, 80, 25)];
    [_nameLabel setBackgroundColor:[UIColor clearColor]];
    [_nameLabel setTextColor:[UIColor whiteColor]];
    [_nameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    [_nameLabel setTextAlignment:NSTextAlignmentCenter];
    [_iconImageView addSubview:_nameLabel];


    
    //lamps IP
     _contentLabel=[[UILabel alloc] init];
    [_contentLabel setFrame:CGRectMake(_iconImageView.frame.size.width/2-50, _titleLabel.frame.origin.y+25, _iconImageView.frame.size.width-40, 30)];
    _contentLabel.numberOfLines=0;
    [_contentLabel setBackgroundColor:[UIColor clearColor]];
    [_contentLabel setTextColor:[UIColor whiteColor]];
    [_contentLabel setFont:[UIFont fontWithName:@"Helvetica" size:8]];
    [_contentLabel setTextAlignment:NSTextAlignmentCenter];
    [_iconImageView addSubview:_contentLabel];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

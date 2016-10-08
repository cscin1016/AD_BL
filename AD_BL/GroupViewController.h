//
//  GroupViewController.h
//  RESideMenuExample
//
//  Created by 3013 on 14-5-30.
//  Copyright (c) 2014年 Roman Efimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>


@property (strong,nonatomic)NSArray *AllDataArray;
@property (strong,nonatomic) CBCentralManager * cbCentralMgr;
@end

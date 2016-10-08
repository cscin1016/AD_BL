//
//  TimerVC.m
//  AD_BL
//
//  Created by apple on 14-6-14.
//  Copyright (c) 2014年 com.aidian. All rights reserved.
//

#import "TimerVC.h"
#import "TimerCell.h"

@interface TimerVC (){
    
    UIDatePicker *datePick;
    NSMutableArray *dateArray;//定时器数组
    
    NSUserDefaults *userDefaults;
    
    NSIndexPath* editRow;
    NSIndexPath* lastSelectRow;
    
    float returnColorRed;
    float returnColorGreen;
    float returnColorBlue;
    
    
    UIView *colorView;
    UIImageView *colorImage;
    UIImageView *imageTip;
    UIButton *SelectOverBtn;
}

@end

@implementation TimerVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//获取当前时间
- (NSString *)getCurrentTime
{
    NSDate *dateNow = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat : @"yyyyMMddHHmmss"];
    return  [formatter stringFromDate:dateNow];
}
-(void)viewDidAppear:(BOOL)animated{
    char strcommand[11]={'s','1','*','#','#','#','#','#','#','#','e'};
    NSString *DataStr=[self getCurrentTime];
    
    strcommand [3] =[[DataStr substringFromIndex:12] intValue];
    strcommand [4] =[[DataStr substringWithRange:NSMakeRange(10, 2)] intValue];
    strcommand [5] =[[DataStr substringWithRange:NSMakeRange(8, 2)] intValue];
    strcommand [6] =[[DataStr substringWithRange:NSMakeRange(6, 2)] intValue]-1;
    strcommand [7] =[[DataStr substringWithRange:NSMakeRange(4, 2)] intValue]-1;
    strcommand [8] =[[DataStr substringWithRange:NSMakeRange(0, 4)] intValue]>>8;
    strcommand [9] =[[DataStr substringWithRange:NSMakeRange(0, 4)] intValue]&0xff;
    NSLog(@"%@",DataStr);
    NSLog(@"%d,%d,%d,%d,%d,%d,%d",strcommand [3],strcommand [4],strcommand [5],strcommand [6],strcommand [7],strcommand [8],strcommand [9]);
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:11];
    NSLog(@"%@",cmdData);
    
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewColorAndBrght" object:nil userInfo:dic];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userDefaults= [NSUserDefaults standardUserDefaults];
    
    //背景图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"app_bg"];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    
    self.title=@"Timer";
    
    datePick=[[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, 320, 216)];
    [datePick setTimeZone: [NSTimeZone systemTimeZone]];
    [datePick setMinimumDate:[NSDate date]];
    // 设置UIDatePicker的显示模式
    [datePick setDatePickerMode:UIDatePickerModeDateAndTime];
    [datePick addTarget:self action:@selector(changeDateAction) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePick];
    
    dateArray=[[NSMutableArray alloc]initWithArray:[userDefaults objectForKey:@"timerDateArray"]];
    
    TimerTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, datePick.frame.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-datePick.frame.size.height-64) style:UITableViewStylePlain];
    
    TimerTableView.backgroundColor=[UIColor clearColor];
    TimerTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    TimerTableView.dataSource=self;
    TimerTableView.delegate=self;
    
    [self.view addSubview:TimerTableView];
    
    [TimerTableView reloadData];
    TimerTableView.contentSize=CGSizeMake(320, [dateArray count]*88);
}
//改变选中cell的时间
-(void)changeDateAction{
    if (editRow!=nil) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        [formatter setTimeZone:timeZone];
        [formatter setDateFormat : @"yyyyMMddHHmmss"];
        NSString *localeDateStr=[formatter stringFromDate:datePick.date];
        
        [formatter setDateFormat : @"yyyy-MM-dd HH-mm-ss"];
        NSString *time=[formatter stringFromDate:datePick.date];
        
        
        NSMutableDictionary *TemDic=[dateArray objectAtIndex:editRow.row];
        
        [TemDic setObject:localeDateStr forKey:@"date"];
        [TemDic setObject:time forKey:@"time"];
        
        [dateArray replaceObjectAtIndex:editRow.row withObject:TemDic];
        [userDefaults setObject:dateArray forKey:@"timerDateArray"];
        [TimerTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:editRow]withRowAnimation:UITableViewRowAnimationNone];
    }else{
        NSLog(@"没有编辑的行，选择时间不改变列表中行的时间");
    }
}
-(void)viewWillAppear:(BOOL)animated{
    
    if (IS_IOS_7) {
        UIBarButtonItem *myAddButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTimerAction)];
        myAddButton.tintColor=[UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = myAddButton;
    }else {
        UIButton *btnRight=[UIButton buttonWithType:UIButtonTypeCustom];
        btnRight.frame=CGRectMake(0, 0, 24, 24);
        [btnRight setBackgroundImage:[UIImage imageNamed:@"add4"] forState:UIControlStateNormal];
        [btnRight addTarget:self action:@selector(addTimerAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btnRight];
    }
    
}
//增加定时器
-(void)addTimerAction{
    if ([dateArray count]>4) {
        return;
    }
    //获得当前UIPickerDate所在的时间
    NSDate *selected = [datePick date];
    NSDate *sinceDate=[NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat : @"yyyyMMddHHmmss"];
    NSString *localeDateStr=[formatter stringFromDate:selected];
    
    [formatter setDateFormat : @"yyyy-MM-dd HH-mm-ss"];
    NSString *time=[formatter stringFromDate:selected];
    
    if ([selected timeIntervalSinceDate:sinceDate]>0) {
        //所选时间必须超过当前时间
        
        int tempReg =(int)[userDefaults integerForKey:@"reg"];
        int tempGreen   =(int)[userDefaults integerForKey:@"green"];
        int tempBlue    =(int)[userDefaults integerForKey:@"blue"];
        int tempWhite   =(int)[userDefaults integerForKey:@"white"];
        
        //寻找通道，如果是按顺序用的，那么当前新建的就是[dateArray count]
        int commandId=(int)[dateArray count]+1;
        for (int i=1; i<=[dateArray count]; i++) {
            for (int j=0; j<[dateArray count]; j++) {
                if ([[[dateArray objectAtIndex:j] objectForKey:@"commandId"] intValue]==i) {
                    break;
                }else if (j==[dateArray count]-1){
                    commandId=i;
                    break;
                }
            }
        }
        
        //commandId:通道ID，1-5
        //status:当前状态，0：定时关，1：定时开，2：取消定时
        NSMutableDictionary *timerTemDic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:localeDateStr,@"date",time,@"time",[NSNumber numberWithInt:commandId],@"commandId",@"0",@"status",[NSNumber numberWithInt:tempReg],@"red",[NSNumber numberWithInt:tempGreen],@"green",[NSNumber numberWithInt:tempBlue],@"blue",[NSNumber numberWithInt:tempWhite],@"white",nil];
        [dateArray addObject:timerTemDic];
        
        [TimerTableView reloadData];
        [userDefaults setObject:dateArray forKey:@"timerDateArray"];
        TimerTableView.contentSize=CGSizeMake(320, [dateArray count]*88);
        [self RTC_ALARM_OFF:localeDateStr];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"TimerView_InvalidTime", @"InfoPlist", nil)  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
}
//定时开
-(void)RTC_ALARM_ON:(NSString*)DataStr{
    char strcommand[11]={'s','3','1','#','#','#','#','#','#','#','e'};
    strcommand [2]=[[[dateArray objectAtIndex:editRow.row] objectForKey:@"commandId"] intValue];
    strcommand [3] =[[DataStr substringFromIndex:12] intValue];
    strcommand [4] =[[DataStr substringWithRange:NSMakeRange(10, 2)] intValue];
    strcommand [5] =[[DataStr substringWithRange:NSMakeRange(8, 2)] intValue];
    strcommand [6] =[[DataStr substringWithRange:NSMakeRange(6, 2)] intValue]-1;
    strcommand [7] =[[DataStr substringWithRange:NSMakeRange(4, 2)] intValue]-1;
    strcommand [8] =[[DataStr substringWithRange:NSMakeRange(0, 4)] intValue]>>8;
    strcommand [9] =[[DataStr substringWithRange:NSMakeRange(0, 4)] intValue]&0xff;
    NSData *cmdData = [NSData dataWithBytes:strcommand length:11];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    
    NSLog(@"%@",DataStr);
    NSLog(@"%d,%d,%d,%d,%d,%d,%d",strcommand [3],strcommand [4],strcommand [5],strcommand [6],strcommand [7],strcommand [8],strcommand [9]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewColorAndBrght" object:nil userInfo:dic];
    
    
}
//定时开之后传颜色
-(void)ARM_ON_COLOR{
    int red=[[[dateArray objectAtIndex:editRow.row] objectForKey:@"red"] intValue];
    int green=[[[dateArray objectAtIndex:editRow.row] objectForKey:@"green"] intValue];
    int blue=[[[dateArray objectAtIndex:editRow.row] objectForKey:@"blue"] intValue];
    int white=[[[dateArray objectAtIndex:editRow.row] objectForKey:@"white"] intValue];
    
    NSLog(@"--------------%d,%d,%d,%d",red,green,blue,white);
    
    char strcommand[11]={'s','4','1','R','G','B','W','*','*','*','e'};
    strcommand [2]=[[[dateArray objectAtIndex:editRow.row] objectForKey:@"commandId"] intValue];
    strcommand [3] =255-red;
    strcommand [4] =255-green;
    strcommand [5] =255-blue;
    strcommand [6] =white;
   
    NSData *cmdData = [NSData dataWithBytes:strcommand length:11];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewColorAndBrght" object:nil userInfo:dic];
}
//定时关
-(void)RTC_ALARM_OFF:(NSString*)DataStr{
    char strcommand[11]={'s','2','1','#','#','#','#','#','#','#','e'};
    //如果选择与没有选择editRow，则怎么处理
    if (editRow!=nil) {
        strcommand [2]=[[[dateArray objectAtIndex:editRow.row] objectForKey:@"commandId"] intValue];
    }else{
        strcommand [2]=[[[dateArray objectAtIndex:[dateArray count]-1] objectForKey:@"commandId"] intValue];
    }
    strcommand [3] =[[DataStr substringFromIndex:12] intValue];
    strcommand [4] =[[DataStr substringWithRange:NSMakeRange(10, 2)] intValue];
    strcommand [5] =[[DataStr substringWithRange:NSMakeRange(8, 2)] intValue];
    strcommand [6] =[[DataStr substringWithRange:NSMakeRange(6, 2)] intValue]-1;
    strcommand [7] =[[DataStr substringWithRange:NSMakeRange(4, 2)] intValue]-1;
    strcommand [8] =[[DataStr substringWithRange:NSMakeRange(0, 4)] intValue]>>8;
    strcommand [9] =[[DataStr substringWithRange:NSMakeRange(0, 4)] intValue]&0xff;
    
    NSLog(@"%@",DataStr);
    NSLog(@"%d,%d,%d,%d,%d,%d,%d",strcommand [3],strcommand [4],strcommand [5],strcommand [6],strcommand [7],strcommand [8],strcommand [9]);
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:11];
   
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewColorAndBrght" object:nil userInfo:dic];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dateArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TimerCell *cell = (TimerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if (cell == nil) {
        cell = [[TimerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row==editRow.row&&editRow!=nil) {
        cell.segment.hidden=NO;
        cell.operationLabel.hidden=YES;
        cell.backgroundColor=[UIColor colorWithRed:27/255.0 green:95/255.0 blue:115/255.0 alpha:1];
        [cell.segment addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];
        cell.titleImage.enabled=YES;
        [cell.titleImage addTarget:self action:@selector(showColorSelect) forControlEvents:UIControlEventTouchUpInside];
    }else{
        cell.segment.hidden=YES;
        cell.operationLabel.hidden=NO;
        cell.backgroundColor=[UIColor clearColor];
        cell.titleImage.enabled=NO;
    }
    
    cell.timeLabel.text=[[dateArray objectAtIndex:indexPath.row] objectForKey:@"time"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if ([[[dateArray objectAtIndex:indexPath.row] objectForKey:@"status"] intValue]==1) {
        int red=[[[dateArray objectAtIndex:indexPath.row] objectForKey:@"red"] intValue];
        int green=[[[dateArray objectAtIndex:indexPath.row] objectForKey:@"green"] intValue];
        int blue=[[[dateArray objectAtIndex:indexPath.row] objectForKey:@"blue"] intValue];
        cell.titleImage.backgroundColor=[UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    }else{
        cell.titleImage.backgroundColor=[UIColor blackColor];
    }
    
    cell.segment.selectedSegmentIndex = [[[dateArray objectAtIndex:indexPath.row] objectForKey:@"status"] intValue];
    
    
    
    
    if ([[[dateArray objectAtIndex:indexPath.row] objectForKey:@"status"]intValue]==0)
    {
        cell.operationLabel.text=[NSString stringWithFormat:@"%@,%@:%@",NSLocalizedStringFromTable(@"TimerView_TimeOFF", @"InfoPlist", nil),NSLocalizedStringFromTable(@"TimerView_Channel", @"InfoPlist", nil),[[dateArray objectAtIndex:indexPath.row] objectForKey:@"commandId"]];
    }
    else if ([[[dateArray objectAtIndex:indexPath.row] objectForKey:@"status"]intValue]==1)
    {
        cell.operationLabel.text=[NSString stringWithFormat:@"%@,%@:%@",NSLocalizedStringFromTable(@"TimerView_TimeON", @"InfoPlist", nil),NSLocalizedStringFromTable(@"TimerView_Channel", @"InfoPlist", nil),[[dateArray objectAtIndex:indexPath.row] objectForKey:@"commandId"]];
    }
    else
    {
        cell.operationLabel.text=[NSString stringWithFormat:@"%@,%@:%@",NSLocalizedStringFromTable(@"TimerView_TimeCancel", @"InfoPlist", nil),NSLocalizedStringFromTable(@"TimerView_Channel", @"InfoPlist", nil),[[dateArray objectAtIndex:indexPath.row] objectForKey:@"commandId"]];
    }
    
    
    return cell;
}
-(void)showColorSelect{
    
    colorView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height-64)];
    colorView.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
    

    colorImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"color_pl"]];
    colorImage.frame=CGRectMake(40, 100, 240, 240);
    [colorView addSubview:colorImage];
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [colorView addGestureRecognizer:tapGesture];
    
    
    imageTip=[[UIImageView alloc]initWithFrame:CGRectMake(120, 140, 14, 13)];
    imageTip.image=[UIImage imageNamed:@"color_cursor"];
    [colorView addSubview:imageTip];
    
    
    
    SelectOverBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    SelectOverBtn.frame=CGRectMake(60, 40, 200, 40);
    [SelectOverBtn addTarget:self action:@selector(selectColorOver) forControlEvents:UIControlEventTouchUpInside];
    [SelectOverBtn setTitle:@"OK" forState:UIControlStateNormal];
    
    [colorView addSubview:SelectOverBtn];
    
    [self.view addSubview:colorView];
}
-(void)selectColorOver{
    [colorView removeFromSuperview];
    
    NSLog(@"selectColorOver");
    NSMutableDictionary *TemDic=[[NSMutableDictionary alloc]initWithDictionary:[dateArray objectAtIndex:editRow.row]];
    [TemDic setObject:[NSNumber numberWithFloat:returnColorRed] forKey:@"red"];
    [TemDic setObject:[NSNumber numberWithFloat:returnColorGreen] forKey:@"green"];
    [TemDic setObject:[NSNumber numberWithFloat:returnColorBlue] forKey:@"blue"];
    [dateArray replaceObjectAtIndex:editRow.row withObject:TemDic];
    [userDefaults setObject:dateArray forKey:@"timerDateArray"];
    [TimerTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:editRow]withRowAnimation:UITableViewRowAnimationNone];
}
-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSMutableDictionary *TemDic=[[NSMutableDictionary alloc]initWithDictionary:[dateArray objectAtIndex:editRow.row]];
    [TemDic setObject:[NSNumber numberWithInteger:Index] forKey:@"status"];
    [dateArray replaceObjectAtIndex:editRow.row withObject:TemDic];
    [userDefaults setObject:dateArray forKey:@"timerDateArray"];
    NSLog(@"%@",dateArray);
    
    [TimerTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:editRow]withRowAnimation:UITableViewRowAnimationNone];
    switch (Index) {
        case 0:
            [self selectmyView1];
            break;
        case 1:
            [self selectmyView2];
            break;
        case 2:
            [self selectmyView3];
            break;
        default:
            break;
    }
}
//定时关
-(void)selectmyView1{
    [self RTC_ALARM_OFF:[[dateArray objectAtIndex:editRow.row] objectForKey:@"date"]];
    
}
//定时开
-(void)selectmyView2{
    [self RTC_ALARM_ON:[[dateArray objectAtIndex:editRow.row] objectForKey:@"date"]];
    [self ARM_ON_COLOR];
}
//取消定时
-(void)selectmyView3{
    NSLog(@"取消定时");
    char strcommand[11]={'s','5','1','*','*','*','*','*','*','*','e'};
    strcommand [2]=[[[dateArray objectAtIndex:editRow.row] objectForKey:@"commandId"] intValue];
    NSData *cmdData = [NSData dataWithBytes:strcommand length:11];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewColorAndBrght" object:nil userInfo:dic];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [dateArray removeObjectAtIndex:indexPath.row];
        editRow=lastSelectRow=nil;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }   
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lastSelectRow=editRow;
    
    editRow=indexPath;
    
    if (lastSelectRow!=nil) {
        if (lastSelectRow.row==editRow.row) {
            lastSelectRow=editRow=nil;
            [tableView reloadData];
            return;
        }
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:lastSelectRow]withRowAnimation:UITableViewRowAnimationNone];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:editRow]withRowAnimation:UITableViewRowAnimationNone];
    
}
- (UIColor *)colorAtPixel:(CGPoint)point {
    point= CGPointMake(point.x,  point.y);
    
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(40.0f,100.0f, colorImage.bounds.size.width,colorImage.bounds.size.height), point)) {
        NSLog(@"不在区域");
        return nil;
    }
    
    NSInteger pointX = trunc(point.x-40);
    NSInteger pointY = trunc(point.y-100);
    CGImageRef cgImage = colorImage.image.CGImage;
    NSUInteger width = colorImage.bounds.size.width;
    NSUInteger height =colorImage.bounds.size.height;
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = {0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast |kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context,kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] /255.0f;
    CGFloat green = (CGFloat)pixelData[1] /255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] /255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] /255.0f;
    
    returnColorRed=pixelData[0];
    returnColorGreen=pixelData[1];
    returnColorBlue=pixelData[2];
    
    SelectOverBtn.backgroundColor=[UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
-(void)tapAction:(UITapGestureRecognizer*) tap {
    CGPoint p = [tap locationInView:tap.view];
    
    imageTip.center=p;
    [self colorAtPixel:p];
    
}


@end

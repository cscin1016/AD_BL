//
//  ViewController.m
//  AD_BL
//
//  Created by 3013 on 14-6-5.
//  Copyright (c) 2014年 com.aidian. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "iflyMSC/IFlyContact.h"
#import "iflyMSC/IFlyDataUploader.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "Definition.h"
#import "iflyMSC/IFlyUserWords.h"
#import "RecognizerFactory.h"
#import "UIPlaceHolderTextView.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "PopupView.h"

#import "sys/utsname.h"
#import "PopupView.h"

//修改灯泡名称时会用到UIAlertViewDelegate
@interface ViewController ()<UIAlertViewDelegate>{
    BOOL canSendMes;//判断是否找到了发送信息的特性
    UILabel *lightIp;
    UILabel *lightName;
    UILabel *numberStr;
    
    IFlySpeechRecognizer    *_iFlyRecognizeControl;//识别控件,recognizer
    UIButton *_recognizeButton;
    
    NSMutableString *allResultString;
    UISegmentedControl *segmentedContol;
}
@end

@implementation ViewController

@synthesize peripheralOpration,openDic;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTable(@"MainView_TITLE", @"InfoPlist", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *backgroundView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 64-(ADJUSTMENT), 320, 568)];
    [backgroundView setImage:[UIImage imageNamed:@"main_bg"]];
    [self.view addSubview:backgroundView];
    
    mainBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [mainBtn setFrame:CGRectMake(70, 84-(ADJUSTMENT), 180, 180)];
    [mainBtn setBackgroundImage:[UIImage imageNamed:@"power_off"] forState:UIControlStateNormal];
    [mainBtn addTarget:self action:@selector(openLight) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mainBtn];
    
    
    UIImageView *downImage=[[UIImageView alloc]initWithFrame:CGRectMake(110, 284-(ADJUSTMENT), 100, 100)];
    [downImage setImage:[UIImage imageNamed:@"light_pl"]];
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeName)];
    downImage.backgroundColor=[UIColor clearColor];
    gesture.numberOfTapsRequired = 2;
    [downImage addGestureRecognizer:gesture];
    downImage.userInteractionEnabled=YES;
    [self.view addSubview:downImage];
    
    
    
    //亮度值label
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    numberStr= [[UILabel alloc] initWithFrame:CGRectMake(20, 20, downImage.frame.size.width-40, 30)];
    numberStr.text=[userDefaults objectForKey:@"brigness"];
    numberStr.text=@"NO";
    numberStr.font =[UIFont systemFontOfSize:26];
    numberStr.backgroundColor=[UIColor clearColor];
    numberStr.textColor =[UIColor colorWithRed:0.0 green:0.9 blue:0.9 alpha:1.0];
    numberStr.textAlignment = NSTextAlignmentCenter;
    [downImage addSubview:numberStr];
    
    //灯泡名称信息label
    lightName= [[UILabel alloc] initWithFrame:CGRectMake(20, 50, downImage.frame.size.width-40, 15)];
    lightName.text=NSLocalizedStringFromTable(@"MainView_Untitled", @"InfoPlist", nil);
    lightName.font =[UIFont systemFontOfSize:10];
    lightName.backgroundColor=[UIColor clearColor];
    lightName.textColor =[UIColor whiteColor];
    lightName.textAlignment = NSTextAlignmentCenter;
    [downImage addSubview:lightName];
    
    //设备ip地址
    lightIp= [[UILabel alloc] initWithFrame:CGRectMake(20, 65, downImage.frame.size.width-40, 10)];
    lightIp.text=[userDefaults objectForKey:@"IP"];
    lightIp.textColor =[UIColor whiteColor];
    lightIp.backgroundColor= [UIColor clearColor];
    lightIp.font =[UIFont fontWithName:@"HelveticaNeue" size:8];
    lightIp.textAlignment = NSTextAlignmentCenter;
    [downImage addSubview:lightIp];
    
    lampsController=[[LampsViewController alloc]init];
    
    openDic=[[NSMutableDictionary alloc]initWithCapacity:0];
    
    if (![self deviceString]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"MainView_SupportALert", @"InfoPlist", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }else if(self.peripheralOpration==nil&&[openDic count]==0) {
        [self.navigationController pushViewController:lampsController animated:YES];
    }
    
    _recognizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recognizeButton.backgroundColor=[UIColor grayColor];
    _recognizeButton.frame = CGRectMake(20, 390-(ADJUSTMENT), 280, 40);
    [_recognizeButton setTitle:NSLocalizedStringFromTable(@"MainView_VoiceControl", @"InfoPlist", nil) forState:UIControlStateNormal];
    [_recognizeButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [_recognizeButton addTarget:self action:@selector(onBtnStart:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recognizeButton];
    

    //创建语音配置
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",APPID_VALUE,TIMEOUT_VALUE];
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
    _iFlySpeechRecognizer = [RecognizerFactory CreateRecognizer:self Domain:@"iat"];
    [_iFlySpeechRecognizer setParameter:@"en_us" forKey:[IFlySpeechConstant LANGUAGE]];
    
    self.uploader = [[IFlyDataUploader alloc] init];
    [self.uploader  setParameter:@"en_us" forKey:@"LANGUAGE"];
    
    self.popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 240, 0, 0)];
    _popUpView.ParentView = self.view;
    
    
    //设置分段控件
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:NSLocalizedStringFromTable(@"Enlish_BUTTON", @"InfoPlist", nil),NSLocalizedStringFromTable(@"Chinese_BUTTON", @"InfoPlist", nil),nil];
    segmentedContol = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    segmentedContol.frame =CGRectMake(0, [[UIScreen mainScreen]bounds].size.height-40-(ADJUSTMENT), [[UIScreen mainScreen]bounds].size.width, 40);
    segmentedContol.selectedSegmentIndex=0;
    segmentedContol.segmentedControlStyle=UISegmentedControlStyleBar;
    [segmentedContol addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedContol];
    
}
-(void)awakeFromNib{
    //注册消息通知
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(updateLightOrGroup:) name:@"peripheralOpration" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(updateColorAndBrght:) name:@"ColorAndBrght" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(updateColorAndBrght:) name:@"NewColorAndBrght" object:nil];
}
//处理分段控件事件
-(void)segmentAction:(UISegmentedControl *)Seg
{
    NSInteger Index = Seg.selectedSegmentIndex;
    switch (Index)
    {
        case 0:
            [_iFlySpeechRecognizer setParameter:@"en_us" forKey:[IFlySpeechConstant LANGUAGE]];
            break;
        case 1:
            [_iFlySpeechRecognizer setParameter:@"zh_cn" forKey:[IFlySpeechConstant LANGUAGE]];
            break;
        default:
            break;
    }
}

//修改名称弹出框
-(void)changeName{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"MainView_ChangeNameALertTitle", @"InfoPlist", nil) message:NSLocalizedStringFromTable(@"MainView_ChangeNameALertMessage", @"InfoPlist", nil) delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    [alert show];
}

//修改名称实现方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.peripheralOpration==nil&&[openDic count]==0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"MainView_NoSelectedLight", @"InfoPlist", nil) delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    char strcommand[15]={'s','2','2',0,0,0,0,0,0,0,0,0,0,0,'e'};
    NSString  *dateStr=[alertView textFieldAtIndex:0].text;
    if ([dateStr length]>15) {
        //仅截取前14个字符
        dateStr=[dateStr substringToIndex:14];
    }
    for (int i=0; i<[dateStr length]; i++) {
        strcommand[i+2]=[dateStr characterAtIndex:i];
    }
    NSData *cmdData = [NSData dataWithBytes:strcommand length:15];
    
    
    //判断是组还是单个灯,如果是单个灯
    if ([openDic count]==0)
    {
        [self sendDatawithperipheral:self.peripheralOpration characteristic:TRANSFER_CHARACTERISTIC_UUID_8 data:cmdData showAlert:YES];
    }
    //如果是一个组
    else
    {
        //找到选择的灯的序号数组
        NSArray *selectGroupArray=[openDic objectForKey:@"groupDic"];
        for (int i=0 ;i<[selectGroupArray count]; i++)
        {
            canSendMes=NO;
            //对每一个序号找到对应的蓝牙对象进行操作
            int m=[[selectGroupArray objectAtIndex:i] intValue];
            CBPeripheral *peripheral=[[openDic objectForKey:@"DataArray"] objectAtIndex:m];
            [self sendDatawithperipheral:peripheral characteristic:TRANSFER_CHARACTERISTIC_UUID_8 data:cmdData showAlert:YES];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if (IS_IOS_7) {
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_cfg"] style:UIBarButtonItemStylePlain target:self action:@selector(SettingAction)];
        self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
    }else{
        UIButton *btnRight=[UIButton buttonWithType:UIButtonTypeCustom];
        btnRight.frame=CGRectMake(0, 0, 25, 44);
        [btnRight setBackgroundImage:[UIImage imageNamed:@"ic_cfg"] forState:UIControlStateNormal];
        [btnRight addTarget:self action:@selector(SettingAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btnRight];
    }
}

-(void)updateColorAndBrght:(NSNotification*) notification{
    if (self.peripheralOpration==nil&&[openDic count]==0) {
        return;
    }
    //如果是单个灯
    if ([openDic count]==0)
    {
        if([[notification name] isEqualToString:@"NewColorAndBrght"])
        {
            //保留找到的特性6,实现跟定时器相关
            [self sendDatawithperipheral:self.peripheralOpration characteristic:TRANSFER_CHARACTERISTIC_UUID_6 data:[[notification userInfo] objectForKey:@"tempData"] showAlert:YES];
        }else
        {
            [self sendDatawithperipheral:self.peripheralOpration characteristic:TRANSFER_CHARACTERISTIC_UUID_1 data:[[notification userInfo] objectForKey:@"tempData"] showAlert:YES];
        }
       
    }
    //如果是群组
    else
    {
        canSendMes=NO;
        //找到选择的灯的序号数组
        NSArray *selectGroupArray=[openDic objectForKey:@"groupDic"];
        for (int i=0 ;i<[selectGroupArray count]; i++)
        {
            canSendMes=NO;
            //对每一个序号找到对应的蓝牙对象进行操作
            int m=[[selectGroupArray objectAtIndex:i] intValue];
            CBPeripheral *peripheral=[[openDic objectForKey:@"DataArray"] objectAtIndex:m];
            
            //判断是否为图片模式下单个灯的控制，如果是则执行if里面内容
            if ([[notification userInfo] objectForKey:@"selectLightMove"] !=nil) {
                //判断是否为当前要操作的灯
                if ([[[notification userInfo] objectForKey:@"selectLightMove"] intValue]==i) {
                    NSLog(@"对分组中%@这个灯单独控制！",peripheral.name);
                }else{
                    continue;
                }
            }
            [self sendDatawithperipheral:peripheral characteristic:TRANSFER_CHARACTERISTIC_UUID_1 data:[[notification userInfo] objectForKey:@"tempData"] showAlert:YES];
        }
    }
}
//通知响应方法，选择某个灯，或某个组之后执行此方法
-(void)updateLightOrGroup:(NSNotification*) notification{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([notification object]!=nil){ //如果是单个灯
        self.peripheralOpration=[notification object];
        lightIp.text=[self.peripheralOpration.identifier UUIDString];
        lightName.text=self.peripheralOpration.name;
        [openDic removeAllObjects];
        [userDefaults setInteger:1 forKey:@"numberOfLight"];
    }else{//如果是一个群组
        openDic=[NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
        [userDefaults setInteger:[[openDic objectForKey:@"groupDic"] count] forKey:@"numberOfLight"];
    }
}
//执行开关灯操作
-(void)openLight{
    if (self.peripheralOpration==nil&&[openDic count]==0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"MainView_NoSelectedLight", @"InfoPlist", nil) delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    isLightOpen=!isLightOpen;
    char strcommand[9]={'s','*','*','*','*','*','1','e'};
    if (isLightOpen)
    {
        numberStr.text=@"ON";
        [mainBtn setBackgroundImage:[UIImage imageNamed:@"power_on"] forState:UIControlStateNormal];
        strcommand[6]=2;
    }else{
        numberStr.text=@"OFF";
        [mainBtn setBackgroundImage:[UIImage imageNamed:@"power_off"] forState:UIControlStateNormal];
        strcommand[6]=1;
    }
    NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
    
    //如果是单个灯
    if ([openDic count]==0)
    {
        BOOL isSendSuccess= [self sendDatawithperipheral:self.peripheralOpration characteristic:TRANSFER_CHARACTERISTIC_UUID_1 data:cmdData showAlert:YES];
        //发送不成功，则更改灯的状态
        if (!isSendSuccess)
        {
            isLightOpen=!isLightOpen;
            if (isLightOpen)
            {
                numberStr.text=@"ON";
                [mainBtn setBackgroundImage:[UIImage imageNamed:@"power_on"] forState:UIControlStateNormal];
            }else
            {
                numberStr.text=@"OFF";
                [mainBtn setBackgroundImage:[UIImage imageNamed:@"power_off"] forState:UIControlStateNormal];
            }
        }
    }
    //如果是一个群组
    else{
        //找到选择的灯的序号数组
        NSArray *selectGroupArray=[openDic objectForKey:@"groupDic"];
        for (int i=0 ;i<[selectGroupArray count]; i++)
        {
            //对每一个序号找到对应的蓝牙对象进行操作
            int m=[[selectGroupArray objectAtIndex:i] intValue];
            CBPeripheral *peripheral=[[openDic objectForKey:@"DataArray"] objectAtIndex:m];
            //即使数据发送失败，也依然是开关灯执行后的状态
            [self sendDatawithperipheral:peripheral characteristic:TRANSFER_CHARACTERISTIC_UUID_1 data:cmdData showAlert:YES];
            
        }
    }
}

//根据蓝牙对象和特性发送数据
-(BOOL)sendDatawithperipheral:(CBPeripheral *)peripheral characteristic:(NSString*)characteristicStr data:(NSData*)data showAlert:(BOOL)isShow{
    canSendMes=NO;
    for (CBCharacteristic *characteristic in [[peripheral.services objectAtIndex:1] characteristics])
    {
        //保留找到的特性1
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:characteristicStr]])
        {
            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            canSendMes=YES;
        }
    }
    if (!canSendMes&&isShow)
    {
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"Send command to %@ error!",peripheral.name] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
//        [alert show];
    }
    return canSendMes;
}

-(void)SettingAction{
    [self.navigationController pushViewController:lampsController animated:YES];
}



//  处理返回的语音数据
- (void)resultStringCheck:(NSString *)sentence
{
    
    char strcommand[8]={'s','*','*','*','*','*','1','e'};
	if ([sentence rangeOfString:@"开"].length  > 0||[sentence rangeOfString:@"open"].length  > 0||[sentence rangeOfString:@"on"].length  > 0) {
        strcommand[6]=2;
    }else if ([sentence rangeOfString:@"关"].length  > 0||[sentence rangeOfString:@"close"].length  > 0||[sentence rangeOfString:@"off"].length  > 0){
        strcommand[6]=1;
    }else if ([sentence rangeOfString:@"绿"].length  > 0||[sentence rangeOfString:@"green"].length  > 0){
        strcommand [1] =255-0;
        strcommand [2] =255-255;
        strcommand [3] =255-0;
        strcommand [4] =255-0;
        strcommand[6] =3;
    }else if ([sentence rangeOfString:@"红"].length  > 0||[sentence rangeOfString:@"red"].length  > 0){
        strcommand [1] =255-255;
        strcommand [2] =255-0;
        strcommand [3] =255-0;
        strcommand [4] =255-0;
        strcommand[6] =3;
    }else if ([sentence rangeOfString:@"蓝"].length  > 0||[sentence rangeOfString:@"blue"].length  > 0){
        strcommand [1] =255-0;
        strcommand [2] =255-0;
        strcommand [3] =255-255;
        strcommand [4] =255-0;
        strcommand[6] =3;
    }else if ([sentence rangeOfString:@"白"].length  > 0||[sentence rangeOfString:@"white"].length  > 0){
        strcommand [1] =0;
        strcommand [2] =0;
        strcommand [3] =0;
        strcommand [4] =255-0;
        strcommand[6] =3;
    }
    else{
        return;
    }
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:8];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorAndBrght" object:nil userInfo:dic];
}



- (BOOL)deviceString
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    return NO;
    if ([deviceString isEqualToString:@"iPhone1,2"])    return NO;
    if ([deviceString isEqualToString:@"iPhone2,1"])    return NO;
    if ([deviceString isEqualToString:@"iPhone3,1"])    return NO;
    if ([deviceString isEqualToString:@"iPhone4,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone5,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone3,2"])    return YES;
    if ([deviceString isEqualToString:@"iPod1,1"])      return NO;
    if ([deviceString isEqualToString:@"iPod2,1"])      return NO;
    if ([deviceString isEqualToString:@"iPod3,1"])      return NO;
    if ([deviceString isEqualToString:@"iPod4,1"])      return NO;
    if ([deviceString isEqualToString:@"iPad1,1"])      return NO;
    if ([deviceString isEqualToString:@"iPad2,1"])      return YES;
    if ([deviceString isEqualToString:@"iPad2,2"])      return YES;
    if ([deviceString isEqualToString:@"iPad2,3"])      return YES;
    if ([deviceString isEqualToString:@"i386"])         return NO;
    if ([deviceString isEqualToString:@"x86_64"])       return NO;
    NSLog(@"NOTE: Unknown device type: %@", deviceString);
    return YES;
}
/*
 * @开始录音
 
 */
/**
 语言
 支持：zh_cn，zh_tw，en_us<br>
+(NSString*)LANGUAGE;
  */
- (void) onBtnStart:(id) sender
{
    if ([((UIButton*)sender).titleLabel.text isEqualToString:NSLocalizedStringFromTable(@"MainView_VoiceControlOver", @"InfoPlist", nil)]) {
        [self onBtnStop:sender];
        return;
    }
    [_recognizeButton setTitle:NSLocalizedStringFromTable(@"MainView_VoiceControlOver", @"InfoPlist", nil) forState:UIControlStateNormal];
    allResultString=[[NSMutableString alloc]initWithCapacity:0];
    self.isCanceled = NO;
    bool ret = [_iFlySpeechRecognizer startListening];
    if (ret) {
        
    }else{
        [_popUpView setText: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束，暂不支持多路并发
        [self.view addSubview:_popUpView];
    }
}

/*
 * @ 暂停录音
 */
- (void) onBtnStop:(id) sender
{
    [_iFlySpeechRecognizer stopListening];
    [_recognizeButton setTitle:NSLocalizedStringFromTable(@"MainView_VoiceControl", @"InfoPlist", nil) forState:UIControlStateNormal];
}

/*
 * @取消识别
 */
- (void) onBtnCancel:(id) sender
{
    self.isCanceled = YES;
    [_iFlySpeechRecognizer cancel];
    [_popUpView removeFromSuperview];
    
}
#pragma mark - IFlySpeechRecognizerDelegate
/**
 * @fn      onVolumeChanged
 * @brief   音量变化回调
 *
 * @param   volume      -[in] 录音的音量，音量范围1~100
 * @see
 */
- (void) onVolumeChanged: (int)volume
{
    if (self.isCanceled) {
        [_popUpView removeFromSuperview];
        return;
    }
    NSString * vol = [NSString stringWithFormat:@"%@：%d",NSLocalizedStringFromTable(@"MainView_Volume", @"InfoPlist", nil),volume];
    [_popUpView setText: vol];
    [self.view addSubview:_popUpView];
}

/**
 * @fn      onBeginOfSpeech
 * @brief   开始识别回调
 *
 * @see
 */
- (void) onBeginOfSpeech
{
    [_popUpView setText: NSLocalizedStringFromTable(@"MainView_VoiceSpeaking", @"InfoPlist", nil)];
    [self.view addSubview:_popUpView];
}

/**
 * @fn      onEndOfSpeech
 * @brief   停止录音回调
 *
 * @see
 */
- (void) onEndOfSpeech
{
    [_popUpView setText: NSLocalizedStringFromTable(@"MainView_VoiceStop", @"InfoPlist", nil)];
    [self.view addSubview:_popUpView];
}


/**
 * @fn      onError
 * @brief   识别结束回调
 *
 * @param   errorCode   -[out] 错误类，具体用法见IFlySpeechError
 */
- (void) onError:(IFlySpeechError *) error
{
    [_recognizeButton setTitle:NSLocalizedStringFromTable(@"MainView_VoiceControl", @"InfoPlist", nil) forState:UIControlStateNormal];
    
    NSString *text ;
    if (self.isCanceled) {
        text = NSLocalizedStringFromTable(@"MainView_VoiceCan", @"InfoPlist", nil);
    }else if (error.errorCode ==0 ) {
        if (_result.length==0) {
            text = NSLocalizedStringFromTable(@"MainView_VoiceNoResult", @"InfoPlist", nil);
        }
    }else{
        text = [NSString stringWithFormat:@"Error：%d %@",error.errorCode,error.errorDesc];
        NSLog(@"发生错误:%@",text);
    }
    [_popUpView setText: text];
    [self.view addSubview:_popUpView];
    
    NSLog(@"显示所有:%@",allResultString);
    [_popUpView setText: allResultString];
    [self.view addSubview:_popUpView];
}

/**
 * @fn      onResults
 * @brief   识别结果回调
 *
 * @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 * @see
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        NSData *data=[key dataUsingEncoding:NSUTF8StringEncoding];
        if (data!=nil) {
            id result =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            for (int i=0;i<[[result objectForKey:@"ws"] count];i++) {
                [resultString appendFormat:@"%@",[[[[[result objectForKey:@"ws"] objectAtIndex:i] objectForKey:@"cw"] objectAtIndex:0]objectForKey:@"w"]];
            }
        }
    }
    NSLog(@"语音识别结果：%@",resultString);
    
    
    [allResultString appendString:resultString];
    NSLog(@"所有:%@",allResultString);
    
    
    self.result = resultString;
    [self resultStringCheck:resultString];
    if (isLast) {
        [_recognizeButton setTitle:NSLocalizedStringFromTable(@"MainView_VoiceControl", @"InfoPlist", nil) forState:UIControlStateNormal];
    }
    else
    {
        NSLog(@"this is not last ");
    }
}

/**
 * @fn      onCancel
 * @brief   取消识别回调
 * 当调用了`cancel`函数之后，会回调此函数，在调用了cancel函数和回调onError之前会有一个短暂时间，您可以在此函数中实现对这段时间的界面显示。
 * @param
 * @see
 */
- (void) onCancel
{
    NSLog(@"识别取消");
    [_recognizeButton setTitle:NSLocalizedStringFromTable(@"MainView_VoiceControl", @"InfoPlist", nil) forState:UIControlStateNormal];
}

-(void)viewWillDisappear:(BOOL)animated
{
//    [_iFlySpeechRecognizer cancel];
//    [_iFlySpeechRecognizer setDelegate: nil];
    [super viewWillDisappear:animated];
}

@end

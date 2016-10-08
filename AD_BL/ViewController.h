//
//  ViewController.h
//  AD_BL
//
//  Created by 3013 on 14-6-5.
//  Copyright (c) 2014年 com.aidian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"


#import "LampsViewController.h"
@class PopupView;
@class IFlyDataUploader;
@class IFlySpeechRecognizer;


@interface ViewController : UIViewController<IFlySpeechRecognizerDelegate>{
    UIButton *mainBtn;//开关按钮
    BOOL isLightOpen;
    LampsViewController *lampsController;//操作灯界面
    
}
@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer;
@property (nonatomic, strong) PopupView            * popUpView;
@property (nonatomic, strong) IFlyDataUploader     * uploader;
@property (nonatomic, strong) NSString             * result;
@property (nonatomic)         BOOL                 isCanceled;

@property (strong,nonatomic)CBPeripheral * peripheralOpration;//一个灯时操作的蓝牙对象
@property (strong,nonatomic)NSMutableDictionary *openDic;//分组时，字典接收来自Lamp类的数据

@end

//
//  TSZMoreViewController.m
//  contactsAddressBook
//
//  Created by tang on 16/4/18.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import "TSZMoreViewController.h"

#import <AddressBook/AddressBook.h>

#import <AddressBookUI/AddressBookUI.h>

#import "TSZABHelper.h"

//#import <CoreTelephony/CoreTelephonyDefines.h>

//#import <CoreTelephony/CTCallCenter.h>
//
//#import <CoreTelephony/CTTelephonyNetworkInfo.h>
//#import <CoreTelephony/CTCarrier.h>
//
//#import <CoreTelephony/CTCall.h>


//#import "TSZGetCallerID.h"
//
//extern NSString const * kCTSMSMessageReceivedNotification;
//extern NSString const * kCTSMSMessageReplaceReceivedNotification;
//extern NSString const * kCTSIMSupportSIMStatusNotInserted;
//extern NSString const * kCTSIMSupportSIMStatusReady;
//
//typedef struct __CTCall CTCall;
//
//extern NSString *CTCallCopyAddress(void*, CTCall *);
//
//void * CTSMSMessageSend(id server,id msg);
//typedef struct __CTSMSMessage CTSMSMessage;
//NSString *CTSMSMessageCopyAddress(void *, CTSMSMessage *);
//NSString *CTSMSMessageCopyText(void *, CTSMSMessage *);
//
//int CTSMSMessageGetRecordIdentifier(void * msg);
//NSString * CTSIMSupportGetSIMStatus();
//NSString * CTSIMSupportCopyMobileSubscriberIdentity();
//
//id CTSMSMessageCreate(void* unknow/*always 0*/,NSString* number,NSString* text);
//void * CTSMSMessageCreateReply(void* unknow/*always 0*/,void * forwardTo,NSString *text);
//
//id CTTelephonyCenterGetDefault(void);
//
//void CTTelephonyCenterAddObserver(id, id, CFNotificationCallback, NSString *, void *,int);
//void CTTelephonyCenterRemoveObserver(id,id,NSString*,void*);
//int CTSMSMessageGetUnreadCount(void);
//
//void * CTCallDisconnect(CTCall *call);



@interface TSZMoreViewController ()
//{
//    CTCallCenter *_center;
//}
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextFiled;


@property (weak, nonatomic) IBOutlet UILabel *resultLabel;


@property (weak, nonatomic) IBOutlet UILabel *operatorLabel;



@end

@implementation TSZMoreViewController

-(void)viewDidLoad{
    
    [super viewDidLoad];
//    id ct = CTTelephonyCenterGetDefault();
//    CTTelephonyCenterAddObserver(ct, NULL, callback, NULL, NULL, CFNotificationSuspensionBehaviorHold);
//    sig_t oldHandler = signal(SIGINT, signalHandler);
//    if (oldHandler == SIG_ERR) {  printf("Could not establish new signal handler");
//        exit(1); }  printf("Starting run loop and watching for notification.\n");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clickQueryPhone:(UIButton *)sender {
    
    NSLog(@" 点击查询 , phone = %@" , self.phoneNumberTextFiled.text);
    
    
    self.resultLabel.text = @"查询中。。。";
    
    
    if ( [self existPhoneNumber:self.phoneNumberTextFiled.text]) {
        
        self.resultLabel.text  = @"查询成功";
    }else{
        
         self.resultLabel.text  = @"没有这个联系人";
    }
}

#pragma mark: 判断这个号码是否存在

- (BOOL)existPhoneNumber:(NSString *)phoneNum{
    
    
    return [[TSZABHelper  shareABHelper] existPhone:phoneNum];
}



// 查询运营商


- (IBAction)queryOperator:(UIButton *)sender {
    
//    // 获取并输出手机的运营商信息
//    [self getCarrierInfo];
//    
//    // 监控通话信息
//    CTCallCenter *center = [[CTCallCenter alloc] init];
//    _center = center;
//    center.callEventHandler = ^(CTCall *call) {
//        NSSet *curCalls = _center.currentCalls;
//        
//        NSLog(@"current calls:%@", curCalls);
//        NSLog(@"call:%@", [call description]);
//    };
    
//    id ct = CTTelephonyCenterGetDefault();
//    CTTelephonyCenterAddObserver(ct,   // center
//                                 NULL, // observer
//                                 callback,  // callback
//                                 NULL,                    // event name (or all)
//                                 NULL,                    // object
//                                 CFNotificationSuspensionBehaviorDeliverImmediately);
//    
    
//    id ct = CTTelephonyCenterGetDefault();
//    CTTelephonyCenterAddObserver(ct, NULL, callback, NULL, NULL, CFNotificationSuspensionBehaviorHold);
//    // Handle Interrupts
//    sig_t oldHandler = signal(SIGINT, signalHandler);
//    if (oldHandler == SIG_ERR)
//    {
//        printf("Could not establish new signal handler");
//        exit(1);
//    }
//    // Run loop lets me catch notifications
//    printf("Starting run loop and watching for notification.\n");
//    //CFRunLoopRun();
    
}

//+(NSString *) phoneNumber {
//    NSString *phone = CTSettingCopyMyPhoneNumber();
//    
//    return phone;
//}

//- (void)getCarrierInfo{
//    
//    //获取运营商
//    
//    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
//    
//    CTCarrier *carrier   = info.subscriberCellularProvider;
//    
//    NSLog(@"carrier  = %@  " , carrier);
//    // 如果运营商变化将更新运营商输出
//    info.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier) {
//        NSLog(@"22222carrier:%@", [carrier description]);
//    };
//    
//    // 输出手机的数据业务信息
//    NSLog(@"Radio Access Technology:%@", info.currentRadioAccessTechnology);
//}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
   [self.phoneNumberTextFiled resignFirstResponder];
    

}

//static void callback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
//    
//    NSString *notifyname = (__bridge NSString *)name;
//    
//    if ([notifyname isEqualToString:@"kCTCallIdentificationChangeNotification"]) {
//        
//        NSDictionary *info = (__bridge NSDictionary *)userInfo;
//        
//        CTCall *call = (__bridge CTCall *)[info objectForKey:@"kCTCall"];
//        
//        NSString *caller = CTCallCopyAddress(NULL, call);
//        
//        NSLog(@"RECEIVED CALL: %@", caller);
//        
//    }
//}
//
//static void signalHandler(int sigraised){
//    
//    printf("--\nInterrupted.\n---");
//    
//    exit(0);
//}

- (IBAction)deletePhoneClick:(UIButton *)sender {
    
//    ABAddressBookRef *
   BOOL flag =  [[TSZABHelper  shareABHelper] deleteContator];
    
    if (flag) {
        
        NSLog(@"删除成功");
        
        UIAlertView *alartView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"删除成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alartView show];
    }else{
        
        UIAlertView *alartView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"删除失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alartView show];
        
    }
}


@end

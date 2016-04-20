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

#import <CoreTelephony/CoreTelephonyDefines.h>

#import <CoreTelephony/CTCallCenter.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <CoreTelephony/CTCall.h>
@interface TSZMoreViewController ()
{
    CTCallCenter *_center;
}
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextFiled;


@property (weak, nonatomic) IBOutlet UILabel *resultLabel;


@property (weak, nonatomic) IBOutlet UILabel *operatorLabel;



@end

@implementation TSZMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
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
    
    // 获取并输出手机的运营商信息
    [self getCarrierInfo];
    
    // 监控通话信息
    CTCallCenter *center = [[CTCallCenter alloc] init];
    _center = center;
    center.callEventHandler = ^(CTCall *call) {
        NSSet *curCalls = _center.currentCalls;
        
        NSLog(@"current calls:%@", curCalls);
        NSLog(@"call:%@", [call description]);
    };
    
}

- (void)getCarrierInfo{
    
    //获取运营商
    
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier   = info.subscriberCellularProvider;
    
    NSLog(@"carrier  = %@  " , carrier);
    // 如果运营商变化将更新运营商输出
    info.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier) {
        NSLog(@"22222carrier:%@", [carrier description]);
    };
    
    // 输出手机的数据业务信息
    NSLog(@"Radio Access Technology:%@", info.currentRadioAccessTechnology);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
   [self.phoneNumberTextFiled resignFirstResponder];
    
}

@end

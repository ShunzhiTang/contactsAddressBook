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
@interface TSZMoreViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextFiled;


@property (weak, nonatomic) IBOutlet UILabel *resultLabel;


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



@end

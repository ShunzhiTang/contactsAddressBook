//
//  ViewController.m
//  contactsAddressBook
//
//  Created by tang on 16/4/15.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import "ViewController.h"


#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@interface ViewController ()

@property (strong , nonatomic) id addressBook;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 请求访问通讯录 初始化数据
    
    [self requestAddressBook];
}

#pragma mark: 请求数据库初始化

- (void)requestAddressBook{
    
    
}

@end

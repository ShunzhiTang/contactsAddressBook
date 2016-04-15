//
//  ViewController.h
//  contactsAddressBook
//
//  Created by tang on 16/4/15.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TSZContactDelegate <NSObject>


// 新增或修改联系人
- (void)editPersonWithFirstName:(NSString *)firstName  lastName:(NSString *)lastName withWorkNumber:(NSString *)workNumber;

// 取消修改或者新增
- (void)cancelEdit;


@end

@interface ViewController : UIViewController


@end


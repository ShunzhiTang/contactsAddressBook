//
//  TSZABHelper.h
//  contactsAddressBook
//
//  Created by tang on 16/4/19.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSZABHelper : NSObject


/**
    单例的实现
 */

+ (TSZABHelper *)shareABHelper;

/**
    查询当前号码
 */

- (BOOL)existPhone:(NSString *)phoneNum;


@end

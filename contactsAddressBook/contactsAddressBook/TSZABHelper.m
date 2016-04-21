//
//  TSZABHelper.m
//  contactsAddressBook
//
//  Created by tang on 16/4/19.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import "TSZABHelper.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface TSZABHelper()

@property (nonatomic , assign) ABAddressBookRef addressBook;

@property (nonatomic , assign) CFArrayRef  recordsArr;
@property (nonatomic ,strong) NSMutableArray  *allPerson;
@end

@implementation TSZABHelper

+ (TSZABHelper *)shareABHelper{
    
    static TSZABHelper *instance;
    
    static dispatch_once_t  onceToken;
    
    dispatch_once(&onceToken, ^{
       
        instance = [[self alloc] init];
    });
    
    return instance;
}



/**
 查询当前号码
 */

- (BOOL)existPhone:(NSString *)phoneNum{
    
    NSLog(@"requestAddressBook = %zd" , [self initAllPerson]);
    
    if ([self initAllPerson]) {
    
    
    // 遍历 全部联系人
    
        NSLog(@" self.recordsArr = %@ " , self.allPerson);
    
       
        @autoreleasepool {
            
        for (int  i = 0;  i <  self.allPerson.count ;  i++) {
        
        ABRecordRef record =  (__bridge ABRecordRef)(self.allPerson[i]);
        
        ABMultiValueRef   items  =  ABRecordCopyValue(record, kABPersonPhoneProperty);
        
        CFArrayRef phoneNumbers = ABMultiValueCopyArrayOfAllValues(items);
            
        
        //有联系人
        
        if (phoneNumbers) {
            
            // 遍历
         
            for (int  j  = 0;  j < CFArrayGetCount(phoneNumbers);  j++) {
                
                NSString *phone  = (NSString *)CFArrayGetValueAtIndex(phoneNumbers, j);
                
                NSString *correctPhone = [self correctFormatPhoneNuber:phone];
                
                
                NSLog(@"phone11 = %@" , phone);
                
                NSLog(@"correctPhone = %@" , correctPhone);
                
                // 判断
                
                if ([correctPhone isEqualToString:phoneNum]) {
                    
                    CFStringRef  flagArr = ABMultiValueCopyLabelAtIndex(items , j);
                    
                    NSLog(@"phone = %@ " , phone);
                    NSLog(@" flagArr = %@" , flagArr);
//                    CFRelease(flagArr);
                    return  YES;
                }
            }
        }
        
            CFRelease(record);
    }
            
    }
        
    CFRelease(self.addressBook);
        
//    return  YES;
        
}
    
    return NO;
}

#pragma mark: 请求数据库初始化

- (BOOL)requestAddressBook{
    
    // 创建通讯录对象
    
    self.addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    // 访问用户通讯录
    
   __block NSUInteger flag;
    
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
        
        if (!granted) {
            
            UIAlertView *alartView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"通讯录没有授权" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alartView show];
            
//            return  NO;
        }else{
            
            
            flag = [self initAllPerson];
            NSLog(@"flag11 = %zd" , flag);
        }
        
    });
    
    NSLog(@"flag = %zd" , flag);
    
    return  flag;
}


- (BOOL)initAllPerson{
    
    self.addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    // 取得授权
    
    ABAuthorizationStatus authorization = ABAddressBookGetAuthorizationStatus() ;
    
    // 如果未授权
    
    if (authorization != kABAuthorizationStatusAuthorized) {
        
        NSLog(@" 尚未获得权限");
        return NO;
    }
    
    // 取得通讯录
    
     CFArrayRef recordsArr= ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    
    self.allPerson = (__bridge NSMutableArray *)(recordsArr);
    
    // 必须手动释放资源
//    CFRelease(self.recordsArr);
    
    return  YES;
}


/**
    去掉括号 或者空格 ，  -
 */

- (NSString *)correctFormatPhoneNuber:(NSString *)phoneNum{
    
    // 去掉两端的 空格
    
    NSString *temp = [phoneNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // 直接使用替换
    
    temp = [temp stringByReplacingOccurrencesOfString:@"(" withString:@""];
    
    temp = [temp stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    temp = [temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    //这个是 测试出来的大 空格
    
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return temp;
}


/**
  删除我插入的联系人
 
 */

- (BOOL)deleteContator{
    
//    NSLog(@"requestAddressBook = %zd" , [self initAllPerson]);
    
    if ([self initAllPerson]) {
        
        
        // 遍历 全部联系人
        
//        NSLog(@" self.recordsArr = %@ " , self.allPerson);
        
        NSUInteger count = 0;
        
        
        @autoreleasepool {
            
            for (int  i = 0;  i <  self.allPerson.count ;  i++) {
                
                ABRecordRef record =  (__bridge ABRecordRef)(self.allPerson[i]);
                
                ABMultiValueRef   items  =  ABRecordCopyValue(record, kABPersonPhoneProperty);
                
                CFArrayRef phoneNumbers = ABMultiValueCopyArrayOfAllValues(items);
                
                
                //有联系人
                
                if (phoneNumbers) {
                    
                    // 遍历
                        
                        NSString *phone  = (NSString *)CFArrayGetValueAtIndex(phoneNumbers, 0);
                        
//                        NSString *correctPhone = [self correctFormatPhoneNuber:phone];
                        
                        
                        NSLog(@"phone11 = %@" , phone);
                        
//                        NSLog(@"correctPhone = %@" , correctPhone);
                        
                        // 判断
                        
                         NSString  *flagArr = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(items , 0);
                        
                        if ([phone isEqualToString:@"13522505750"] && [flagArr isEqualToString:@"销售电话"]) {
                            
                           
                            
                            NSLog(@"phone = %@ " , phone);
                            NSLog(@" flagArr = %@" , flagArr);
                            
                            // 删除
                            ABAddressBookRemoveRecord(self.addressBook, record, NULL);
                            
                            // 保存电话本
                            
                            count++;
                            
                            continue;
                           
                    }else if ([phone isEqualToString:@"13522866320"] && [flagArr isEqualToString:@"销售电话"]) {
                        
                        
                        
                        NSLog(@"phone = %@ " , phone);
                        NSLog(@" flagArr = %@" , flagArr);
                        
                        // 删除
                        ABAddressBookRemoveRecord(self.addressBook, record, NULL);
                        
                        // 保存电话本
                        
                        count++;
                        
                        continue;
                        
                    }else if ([phone isEqualToString:@"13832365630"] && [flagArr isEqualToString:@"销售电话"]) {
                        
                        
                        
                        NSLog(@"phone = %@ " , phone);
                        NSLog(@" flagArr = %@" , flagArr);
                        
                        // 删除
                        ABAddressBookRemoveRecord(self.addressBook, record, NULL);
                        
                        // 保存电话本
                        
                        count++;
                        
                        continue;
                        
                    }
                    
                }
                
                CFRelease(record);
            }
            
        }
        
        ABAddressBookSave(self.addressBook, NULL);
        
        CFRelease(self.addressBook);
        
        if (count > 0 ) {
            
            return YES;
        }
        
    }
    
    
    return NO;
}



@end

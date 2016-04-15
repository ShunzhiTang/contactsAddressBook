
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

@interface ViewController ()<UITableViewDelegate , UITableViewDataSource>

@property (nonatomic , assign) ABAddressBookRef addressBook;

@property (nonatomic ,strong) NSMutableArray  *allPonser;


// 一个显示数据的tableView
@property (nonatomic ,strong) UITableView  *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 请求访问通讯录 初始化数据
    
    [self requestAddressBook];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
}

#pragma mark: 请求数据库初始化

- (void)requestAddressBook{
    
    // 创建通讯录对象
    
    self.addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    // 访问用户通讯录
    
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
        
        if (!granted) {
            
            UIAlertView *alartView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"通讯录没有授权" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alartView show];
        }else{
            
            
            [self initAllPerson];
        }
        
    });
    
}


- (void)initAllPerson{
    
    // 取得授权
    
    ABAuthorizationStatus authorization = ABAddressBookGetAuthorizationStatus() ;
    
    // 如果未授权
    
    if (authorization != kABAuthorizationStatusAuthorized) {
        
        NSLog(@" 尚未获得权限");
        return;
    }
    
    // 取得通讯录
    
    CFArrayRef  allPerson = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    
    self.allPonser = (__bridge NSMutableArray *)(allPerson);
    
    // 必须手动释放资源
    CFRelease(allPerson);
    
}

#pragma mark: uitableview 的代理


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  self.allPonser.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell  == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    // 取得一条人员记录
    
    ABRecordRef *recordRef = (__bridge ABRecordRef)self.allPonser[indexPath.row];
    
    NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(recordRef, kABPersonFirstNameProperty));
    
    NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(recordRef, kABPersonLastNamePhoneticProperty));
    
    ABMultiValueRef phoneNumberRef = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
    
    long count = ABMultiValueGetCount(phoneNumberRef);
    
    cell.detailTextLabel.text = (__bridge NSString * _Nullable)(ABMultiValueCopyValueAtIndex(phoneNumberRef, 0));
    
    if (firstName) {
        
        cell.textLabel.text = firstName;
        
    }else{
        
        cell.textLabel.text = lastName;
    }
    
    
    if (ABPersonHasImageData(recordRef)) {
        
        NSData *image = (__bridge NSData *)(ABPersonCopyImageData(recordRef));
        
        cell.imageView.image = [UIImage imageWithData:image];
        
    }else{
        
         cell.imageView.image = [UIImage imageNamed:@"noloading"];
        
    }
    
    // 使用cell的tag 记录id
    
    cell.tag = ABRecordGetRecordID(recordRef);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
    
}

@end

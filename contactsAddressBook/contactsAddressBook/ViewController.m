
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
#import "TSZAddPersonViewController.h"

@interface ViewController ()<UITableViewDelegate , UITableViewDataSource , TSZContactDelegate , ABNewPersonViewControllerDelegate>

@property (nonatomic , assign) ABAddressBookRef addressBook;

@property (nonatomic ,strong) NSMutableArray  *allPonser;


// 一个显示数据的tableView
@property (nonatomic ,strong) UITableView  *tableView;

@property (nonatomic ,assign) BOOL isModify;

@property (nonatomic ,strong  ) UITableViewCell *selectedCell;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 请求访问通讯录 初始化数据
    
    [self requestAddressBook];
    
    // 创建一个批量插入的按钮
    
    CGFloat with = self.view.bounds.size.width;
    
    UIButton *moreInsertContacts = [[UIButton alloc] initWithFrame:CGRectMake(20, 74, with-40, 44)];
    
    [moreInsertContacts addTarget:self action:@selector(moreInsertContactsClick) forControlEvents:UIControlEventTouchUpInside];
    
    [moreInsertContacts setTitle:@"批量插入联系人" forState:UIControlStateNormal];
    
    [moreInsertContacts setTintColor:[UIColor whiteColor]];
    
    // 设置背景颜色
    [moreInsertContacts setBackgroundColor: [UIColor grayColor]];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 128, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    [self.view addSubview:moreInsertContacts];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView setEditing:YES animated:YES];
    
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
     [self initAllPerson];
    [self.tableView reloadData];
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
    
    
//    NSLog(@"all = %@" , self.allPonser);
    
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
    
//    NSLog(@" count = %zd" , count);
    
    
    cell.detailTextLabel.text = (__bridge NSString * _Nullable)(ABMultiValueCopyValueAtIndex(phoneNumberRef, 0));
    
    if(firstName == nil){
        
        firstName = @"";
    }
    
    if(lastName == nil){
        
        lastName = @"";
    }
    
    NSString *name = [NSString stringWithFormat:@"%@ %@" , firstName , lastName];
    
    cell.textLabel.text = name;
    
//    if (firstName) {
//        
//        
//    }else{
//        
//        cell.textLabel.text = lastName;
//    }
    
    
    if (ABPersonHasImageData(recordRef)) {
        
        NSData *image = (__bridge NSData *)(ABPersonCopyImageData(recordRef));
        
        cell.imageView.image = [UIImage imageWithData:image];
        
    }else{
        
         cell.imageView.image = [UIImage imageNamed:@"noloading"];
        
    }
    
    // 使用cell的tag 记录id
    
    cell.tag = ABRecordGetRecordID(recordRef);
    
//    CFRelease(recordRef);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        ABRecordRef  recordRef = (__bridge ABRecordRef)(self.allPonser[indexPath.row]);
        
        // 通讯录删除
        
        [self removePersonWithRecord:recordRef];
        
        // 从数组中删除
        
        [self.allPonser removeObjectAtIndex:indexPath.row];
        // 在表格中删除
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }else if(editingStyle == UITableViewCellEditingStyleInsert){
        
        // 应该插入的是联系人
        
//        NSArray *insertArray =  [NSArray arrayWithObjects:indexPath, nil];
//        
//        [self.allPonser insertObject:@"唐枫" atIndex:indexPath.row];
//        
//        [tableView insertRowsAtIndexPaths:insertArray withRowAnimation:UITableViewRowAnimationMiddle];
        
        ABNewPersonViewController *newPerson = [[ABNewPersonViewController alloc] init];
        
        newPerson.newPersonViewDelegate = self;
        
        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:newPerson];
        
        [self presentViewController:navc animated:YES completion:nil];
        
    }
}

// 选择

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.isModify = 1;
    
    self.selectedCell  = [tableView cellForRowAtIndexPath:indexPath];
    
//    self perfromse
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }else {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark: TSZContactDelegate代理方法


- (void)editPersonWithFirstName:(NSString *)firstName lastName:(NSString *)lastName withWorkNumber:(NSString *)workNumber{
    
    
    if (self.isModify) {
        
        UITableViewCell  *cell = self.selectedCell;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        [self modifyPersonWithRecordID:(ABRecordID)cell.tag firstName:firstName lastName:lastName workNumber:workNumber];
        
        [self.tableView  reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }else{
        
        [self  addPersonWithFirstName:firstName lastName:lastName workNumber:workNumber];
        
        [self initAllPerson];
        
        [self.tableView reloadData];
    }
    
    self.isModify = 0;

}


- (void)cancelEdit{
    
    self.isModify = 0;
}


- (void)removePersonWithRecord:(ABRecordRef) recordref{
    
    ABAddressBookRemoveRecord(self.addressBook, recordref, NULL);
    
    // 一定记住删除之后要保存
    
    ABAddressBookSave(self.addressBook, NULL);
}


/** 
    
    根据 姓名删除 记录
 
 */

- (void)removePersonWithName:(NSString *)personName{
    
    
    CFStringRef  personNameRef =  (__bridge CFStringRef)(personName);
    
    
    CFArrayRef  recordsRef = ABAddressBookCopyPeopleWithName(self.addressBook, personNameRef);
    
    CFIndex  count  = CFArrayGetCount(recordsRef); // 取得记录数
    
    for (CFIndex  i = 0 ; i != count;  i++) {
        
        ABRecordRef  recordRef  = CFArrayGetValueAtIndex(recordsRef, i);
        
        // 删除
        ABAddressBookRemoveRecord(self.addressBook, recordRef, NULL);
        
    }
    
    // 一定要保存
    
    ABAddressBookSave(self.addressBook, NULL);
    
    CFRelease(recordsRef);

}



// 跳过


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ( [segue.identifier  isEqualToString:@"AddPerson"]) {
        
        UINavigationController *navgationVC = (UINavigationController *)segue.destinationViewController;
        
        TSZAddPersonViewController  *addVc = (TSZAddPersonViewController *)navgationVC.topViewController;
        
//        addVc.delegate = self;
        
        // 根据选择的cell 去修改
        
        if (self.isModify) {
            
            UITableViewCell *cell = self.selectedCell;
            
            addVc.recordID = (ABRecordID)cell.tag;
            
            NSArray *array = [cell.detailTextLabel.text componentsSeparatedByString:@""];
            
            if (array.count >0) {
                
                addVc.firstNameText = [array firstObject];
            }
            
            if (array.count > 1) {
                
                addVc.lastNameText = [array lastObject];
            }
        }
    }
}


// 修改 联系人

- (void)modifyPersonWithRecordID:(ABRecordID)record firstName:(NSString *)firstName  lastName:(NSString *)lastName  workNumber:(NSString *)workNumber{
    
    
    ABRecordRef  recordRef = ABAddressBookGetPersonWithRecordID(self.addressBook, record);
    
    
    ABRecordSetValue(recordRef, kABPersonFirstNameProperty , (__bridge CFTypeRef)(firstName), NULL);
    
    ABRecordSetValue(recordRef, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), NULL);
    
    
    
    ABMutableMultiValueRef mutilValue = ABMultiValueCreateMutable(kABStringPropertyType);
    
    ABMultiValueAddValueAndLabel(mutilValue, (__bridge CFTypeRef)(workNumber), kABWorkLabel, NULL);
    
    ABRecordSetValue(recordRef, kABPersonPhoneProperty, mutilValue, NULL);
    
    // 保存
    
    ABAddressBookSave(self.addressBook, NULL);
    
    // 释放
    CFRelease(mutilValue);
    
}



- (void)addPersonWithFirstName:(NSString *)firstName lastName:(NSString *)lastName workNumber:(NSString *)workNumber{
    
    ABRecordRef recordRef = ABPersonCreate();
    
    
    ABRecordSetValue(recordRef, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), NULL);
    
    ABRecordSetValue(recordRef, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), NULL);
 
    ABMutableMultiValueRef  multivalueRef  =  ABMultiValueCreateMutable(kABStringPropertyType);
    
    ABMultiValueAddValueAndLabel(multivalueRef, (__bridge CFTypeRef)(workNumber), kABWorkLabel, NULL);
    
    ABRecordSetValue(recordRef , kABPersonPhoneProperty, multivalueRef, NULL);
    
    // 保存
    
    ABAddressBookSave(self.addressBook, NULL);
    
    CFRelease(recordRef);
    CFRelease(multivalueRef);
    
}

#pragma mark: 移动tableView的cell

/**
    
    先把默认的删除的图标去掉
 
 */

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //return UITableViewCellEditingStyleDelete;  // 删除
    
    return UITableViewCellEditingStyleInsert;
}

/**
    2、返回当前的cell 是否可以移动
 */

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return  YES;
}

/**
    3、执行移动的操作
 */


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    NSUInteger  fromRow = [sourceIndexPath  row];
    
    NSUInteger  toRow = [destinationIndexPath   row];
    
    id object = [self.allPonser  objectAtIndex:fromRow];
    
    [self.allPonser removeObjectAtIndex:fromRow];
    
    [self.allPonser  insertObject:object atIndex:toRow];
}

#pragma mark: ABNewPersonViewControllerDelegate方法


- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person{
    
    
    if (person) {
        
        NSLog(@"点击了保存  ， %@", ABRecordCopyCompositeName(person));
        
    }else{
        
        NSLog(@"点击了取消");
    }
    // 关闭
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    //重新请求值
    
    [self initAllPerson];
    
    // 刷新界面
    
    [self.tableView reloadData];
}

#pragma mark: 批量插入联系人

- (void)moreInsertContactsClick{
    
    // 插入 3个 联系人  ， 每个联系人下 3个电话
    
    // 确定数据   name , phone1  , phone2 ,phone3 ...
   
    NSMutableArray *arrayPhones = [NSMutableArray arrayWithCapacity:3000];
    
    for (int x = 0;  x < 3000; x++ ) {
        
        NSString  *number = [NSString stringWithFormat:@"1352250575%d" , x];
        
        [arrayPhones addObject:number];
    }
    
//    NSArray *numArr1 = @[@"TimeA" , @"13522505759" ,@"1331000002"];
    
    NSDictionary *dict1 = @{@"name" : @"" , @"phoneNumbers" : arrayPhones};
    
    NSArray *numArr2 = @[@"TimeB" , @"1361000221" ,@"1361000002"];
    
    NSDictionary *dict2 = @{@"name" : @"" , @"phoneNumbers" : arrayPhones};
    
    NSArray *numArr3 = @[@"TimeC" , @"13710002201" ,@"1371000002"];
    
    NSDictionary *dict3 = @{@"name" : @"" , @"phoneNumbers" : arrayPhones};
    
    NSArray *personArr1 = [NSArray arrayWithObjects:dict1 , dict2 , dict3, nil];
    
    // 记录时间
    
    long oldTime = [[NSDate alloc]init].timeIntervalSince1970;
    
    
//    for ( int i  = 0;  i < 1000; i++) {
    
        for (int i  = 0;  i < [personArr1 count]; i++) {
            
            [self addMoreContactsWith:personArr1[i]];
        }
        
//    }
    
    
    long nowTime = [[NSDate alloc]init].timeIntervalSince1970;

    
    NSLog(@"耗时 ： %ld" , nowTime - oldTime);
    
    
    //重新请求值
    
    [self initAllPerson];
    
    // 刷新界面
    
    [self.tableView reloadData];
}

- (void)addMoreContactsWith:(NSDictionary *)dict{
    
    // 创建 一个联系人引用
    
    ABRecordRef person = ABPersonCreate();
    
    NSString *firstName = dict[@"name"];
    
    // 电话号码组
    
    NSArray *phoneArr = dict[@"phoneNumbers"];
    
    NSArray *labelsArr = @[@"标记" , @"诈骗电话" , @"销售电话"];
    
    
    // 设置姓名属性
    
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), NULL);
    
    // 字典引用
    
    ABMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    // 添加电话号码内容
    
//    for ( int j  = 0;  j < 1000; j++) {
    
        for (int  i = 0 ; i < phoneArr.count; i++) {
            
            ABMultiValueIdentifier obj = ABMultiValueAddValueAndLabel( multiValue, (__bridge CFTypeRef)([phoneArr objectAtIndex:i]), (__bridge CFStringRef)labelsArr[2], &obj);
        }
//    }
    
    
    // 设置phone 属性
    
    ABRecordSetValue(person, kABPersonPhoneProperty, multiValue, NULL);
    
    // 添加图片
    
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"mobobox.png" ofType:nil];
//    
//     NSLog(@"imagePath = %@" , imagePath);
//    
//    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
//    
//    NSLog(@"%@" , imageData);
    
    UIImage *image = [UIImage imageNamed:@"splash"];
    
    NSData *data =  UIImagePNGRepresentation(image);
    
    ABPersonSetImageData(person, (__bridge CFDataRef)data, NULL);
    
    // 保存
    
    ABAddressBookAddRecord(self.addressBook, person, NULL);
    
    // 保存 通讯录
    
    ABAddressBookSave(self.addressBook , NULL);
    
    //release
    
    CFRelease(person);
}


@end

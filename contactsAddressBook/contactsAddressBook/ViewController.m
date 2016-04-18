
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
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    [self.tableView setEditing:YES animated:YES];
    
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
    
    // 刷新界面
    
    [self.tableView reloadData];
}

@end

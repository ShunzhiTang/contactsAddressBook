
#import "WCCallInspector.h"
#import "WCCallCenter.h"
//#import <AudioToolbox/AudioToolbox.h>

@interface WCCallInspector ()
@property (nonatomic,strong) WCCallCenter *callCenter;
@end


@implementation WCCallInspector

+ (instancetype)sharedInspector
{
    static WCCallInspector *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[WCCallInspector alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
#pragma mark - Call Inspection
- (void)startInspect
{
    if (self.callCenter) {
        return;
    }
    self.callCenter = [[WCCallCenter alloc] init];
    __weak WCCallInspector *weakSelf =self;
    self.callCenter.callEventHandler = ^(WCCall *call) {
        
        NSLog(@"%@  + + %@" ,call.phoneNumber  , call.internalCall);
        
        [weakSelf handleCallEvent:call];
    };
}
#pragma mark 呼出,呼入,接通,挂断
- (void)handleCallEvent:(WCCall *)call{
    //这里 想怎么操作 根据自己情况而定啊......
    //可以打印call的属性看看结果
    //    kCTCallStatusConnected = 1, //已接通
    //    kCTCallStatusCallOut = 3, //拨出去
    //    kCTCallStatusCallIn = 4, //打进来
    //    kCTCallStatusHungUp = 5 //挂断
    
    NSLog(@"%zd" , call.callStatus);
}

@end
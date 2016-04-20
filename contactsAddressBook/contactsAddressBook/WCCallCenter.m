



#import "WCCallCenter.h"
#import <dlfcn.h> //引用 这个框架
//#import <AudioToolbox/AudioToolbox.h>
#import "WCUtil.h"

// encrypted string's
#define ENCSTR_kCTCallStatusChangeNotification  [@"n0AHD2SfoSA0LKE1p0AbLJ5aMH5iqTyznJAuqTyiot==" wcDecryptString]
#define ENCSTR_kCTCall                          [@"n0AHD2SfoN==" wcDecryptString]
#define ENCSTR_kCTCallStatus                    [@"n0AHD2SfoSA0LKE1pj==" wcDecryptString]
#define ENCSTR_CTTelephonyCenterGetDefault      [@"D1EHMJkypTuioayQMJ50MKWUMKERMJMuqJk0" wcDecryptString]
#define ENCSTR_CTTelephonyCenterAddObserver     [@"D1EHMJkypTuioayQMJ50MKWOMTECLaAypaMypt==" wcDecryptString]
#define ENCSTR_CTTelephonyCenterRemoveObserver  [@"D1EHMJkypTuioayQMJ50MKWFMJ1iqzICLaAypaMypt==" wcDecryptString]
#define ENCSTR_CTCallCopyAddress                [@"D1EQLJkfD29jrHSxMUWyp3Z=" wcDecryptString]
#define ENCSTR_CTCallDisconnect                 [@"D1EQLJkfETymL29hozIwqN==" wcDecryptString]

//这里需要对字符串 NSString 进行拓展方法
//#import <dlfcn.h> 引用 这个框架

/**
 - (NSString *)wcRot13
 {
 const char *source = [selfcStringUsingEncoding:NSASCIIStringEncoding];
 char *dest = (char *)malloc((self.length +1) * sizeof(char));
 if (!dest) {
 return nil;
 }
 
 NSUInteger i = 0;
 for ( ; i < self.length; i++) {
 char c = source[i];
 if (c >= 'A' && c <='Z') {
 c = (c - 'A' + 13) % 26 + 'A';
 }
 else if (c >='a' && c <= 'z') {
 c = (c - 'a' + 13) % 26 + 'a';
 }
 dest[i] = c;
 }
 dest[i] = '\0';
 
 NSString *result = [[NSStringalloc] initWithCString:destencoding:NSASCIIStringEncoding];
 free(dest);
 
 return result;
 }
 - (NSString *)wcDecryptString
 {
 NSString *rot13 = [selfwcRot13];
 NSData *data;
 if ([NSDatainstancesRespondToSelector:@selector(initWithBase64EncodedString:options:)]) {
 data = [[NSDataalloc] initWithBase64EncodedString:rot13options:0]; // iOS 7+
 } else {
 data = [[NSData alloc] initWithBase64Encoding:rot13];                          // pre iOS7
 }
 return [[NSStringalloc] initWithData:dataencoding:NSUTF8StringEncoding];
 }
 **/


// private API
//extern NSString *CTCallCopyAddress(void*, CTCall *);
typedef NSString *(*PF_CTCallCopyAddress)(void*,CTCall *);

//extern void CTCallDisconnect(CTCall *);
typedef void (*PF_CTCallDisconnect)(CTCall *);

//extern CFNotificationCenterRef CTTelephonyCenterGetDefault();
typedef CFNotificationCenterRef (*PF_CTTelephonyCenterGetDefault)();

typedef void (*PF_CTTelephonyCenterAddObserver)(CFNotificationCenterRef center,
const void *observer,
CFNotificationCallback callBack,
CFStringRef name,
const void *object,
CFNotificationSuspensionBehavior suspensionBehavior);

typedef void (*PF_CTTelephonyCenterRemoveObserver)(CFNotificationCenterRef center,
const void *observer,
CFStringRef name,
const void *object);


@interface WCCallCenter ()

- (void)handleCall:(CTCall *)call withStatus:(CTCallStatus)status;

@end

@implementation WCCallCenter

- (id)init
{
    self = [super init];
    if (self) {
        [self registerCallHandler];
    }
    return self;
}

- (void)dealloc
{
    [self deregisterCallHandler];
}

- (void)registerCallHandler
{
    static PF_CTTelephonyCenterAddObserver AddObserver;
    static PF_CTTelephonyCenterGetDefault GetCenter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AddObserver = [WCDL loadSymbol:ENCSTR_CTTelephonyCenterAddObserver];
        GetCenter = [WCDL loadSymbol:ENCSTR_CTTelephonyCenterGetDefault];
    });
    AddObserver(GetCenter(),
                (__bridge void *)self,
                &callHandler,
                (__bridge CFStringRef)(ENCSTR_kCTCallStatusChangeNotification),
                NULL,
                CFNotificationSuspensionBehaviorHold);
}
- (void)deregisterCallHandler
{
    static PF_CTTelephonyCenterRemoveObserver RemoveObserver;
    static PF_CTTelephonyCenterGetDefault GetCenter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RemoveObserver = [WCDL loadSymbol:ENCSTR_CTTelephonyCenterRemoveObserver];
        GetCenter = [WCDL loadSymbol:ENCSTR_CTTelephonyCenterGetDefault];
    });
    
    RemoveObserver(GetCenter(),
                   (__bridge void *)self,
                   (__bridge CFStringRef)(ENCSTR_kCTCallStatusChangeNotification),
                   NULL);
}

- (void)handleCall:(CTCall *)call withStatus:(CTCallStatus)status
{
    
    static PF_CTCallCopyAddress CopyAddress;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CopyAddress = [WCDL loadSymbol:ENCSTR_CTCallCopyAddress];
    });
    
    if (!self.callEventHandler || !call) {
        return;
    }
    
    WCCall *wcCall = [[WCCall alloc] init];
    wcCall.phoneNumber = CopyAddress(NULL, call);
    wcCall.phoneNumber = wcCall.phoneNumber;
    wcCall.callStatus = status;
    wcCall.internalCall = call;
    
    self.callEventHandler(wcCall);
}

static void callHandler(CFNotificationCenterRef center,
                        void *observer,
                        CFStringRef name,
                        const void *object,
                        CFDictionaryRef userInfo)
{
    if (!observer) {
        return;
    }
    
    NSDictionary *info = (__bridge NSDictionary *)(userInfo);
    CTCall *call = (CTCall *)info[ENCSTR_kCTCall];
    
    CTCallStatus status = (CTCallStatus)[info[ENCSTR_kCTCallStatus]shortValue];
    
    if ([[call description] rangeOfString:@"status = 196608"].location==NSNotFound) {
        //这里之后就是你对归属地信息的操作了
        WCCallCenter *wcCenter = (__bridge WCCallCenter*)observer;
        [wcCenter handleCall:call withStatus:status];
        
    }
}

- (void)disconnectCall:(WCCall *)call
{
    static PF_CTCallDisconnect Disconnect;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Disconnect = [WCDL loadSymbol:ENCSTR_CTCallDisconnect];
    });
    
    CTCall *ctCall = call.internalCall;
    if (!ctCall) {
        return;
    }
    
    Disconnect(ctCall);
}

@end
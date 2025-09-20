//
//  ManagerWrapper.mm
//  FlowBridge-Example
//
//  Created by Daniil Arsentev on 18.09.2025.
//

#import "ManagerWrapper.h"
#import "Loader.hpp"

@implementation ManagerWrapper {
    Loader *_loader;
}

+ (instancetype)shared {
    static ManagerWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)startDownloadWithURL:(NSString *)url destFileName:(NSString *)destFileName {
    if (!_loader) _loader = new Loader();
    _loader->start(url.UTF8String, destFileName.UTF8String);
}

- (void)cancelDownload {
    if (_loader) {
        _loader->cancel();
        delete _loader;
        _loader = nullptr;
    }
}

- (void)dealloc {
    [self cancelDownload];
}

@end

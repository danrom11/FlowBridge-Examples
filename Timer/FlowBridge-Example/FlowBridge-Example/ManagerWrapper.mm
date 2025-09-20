//
//  ManagerWrapper.mm
//  FlowBridge-Example
//
//  Created by Daniil Arsentev on 18.09.2025.
//

#import "ManagerWrapper.h"
#import "Timer.hpp"

@implementation ManagerWrapper {
    Timer *_timer; // hold the C++ timer as an ivar
}

+ (instancetype)shared {
    static ManagerWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)startWithInterval:(NSInteger)intervalMs {
    if (_timer) {
        // already created - stop and recreate if a new interval is needed
        _timer->stop();
        delete _timer;
        _timer = nullptr;
    }
    _timer = new Timer((int)intervalMs);
    _timer->start();
}

- (void)stop {
    if (_timer) {
        _timer->stop();
        delete _timer;
        _timer = nullptr;
    }
}

- (void)dealloc {
    [self stop];
}

@end

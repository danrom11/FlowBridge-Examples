//
//  ManagerWrapper.h
//  FlowBridge-Example
//
//  Created by Daniil Arsentev on 18.09.2025.
//

#ifndef ManagerWrapper_h
#define ManagerWrapper_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ManagerWrapper : NSObject

+ (instancetype)shared;

/// Start the timer (interval in ms)
- (void)startWithInterval:(NSInteger)intervalMs;

/// Stop the timer
- (void)stop;

@end

NS_ASSUME_NONNULL_END


#endif /* ManagerWrapper_h */

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

// Start downloading
- (void)startDownloadWithURL:(NSString *)url destFileName:(NSString *)destFileName;

// Cancel the current download
- (void)cancelDownload;

@end

NS_ASSUME_NONNULL_END


#endif /* ManagerWrapper_h */

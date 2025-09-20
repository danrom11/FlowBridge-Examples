//
//  Loader.mm
//  FlowBridge-Example
//
//  Created by Daniil Arsentev on 20.09.2025.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Loader.hpp"
#import <FlowBridge.h> // ObjC-bridge for emit/connect from Objective-C

@interface __FlowLoaderDelegate : NSObject <NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, copy)   NSString *destFileName;
@end

@implementation __FlowLoaderDelegate

// Progress in chunks (periodic)
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (totalBytesExpectedToWrite <= 0) return;
    double p = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    [FlowBridge emit:@(Loader::Signals::progress) data:@(p)];
}

// Completion: move to internal storage and send finished
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    // Documents/<destFileName>
    NSURL *docs = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                          inDomains:NSUserDomainMask] firstObject];
    NSURL *dest = [docs URLByAppendingPathComponent:self.destFileName];

    // Delete if it already exists
    [[NSFileManager defaultManager] removeItemAtURL:dest error:nil];

    NSError *moveErr = nil;
    if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:dest error:&moveErr]) {
        NSString *errStr = moveErr.localizedDescription ?: @"Move error";
        [FlowBridge emit:@(Loader::Signals::error) data:errStr];
        return;
    }

    [FlowBridge emit:@(Loader::Signals::progress) data:@(1.0)];
    [FlowBridge emit:@(Loader::Signals::finished) data:dest.path];
}

// Task error / cancel
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        if (error.code == NSURLErrorCancelled) {
            [FlowBridge emit:@(Loader::Signals::error) data:@"Cancelled"];
        } else {
            NSString *errStr = error.localizedDescription ?: @"Download error";
            [FlowBridge emit:@(Loader::Signals::error) data:errStr];
        }
    }
}

// Cancel with clear
- (void)cancel {
    [self.task cancel];
    [self.session invalidateAndCancel];
}

@end


// ====================== C++ shell ======================

struct Loader::Impl {
    __strong __FlowLoaderDelegate *delegate = nil;
};

Loader::Loader() : impl_(new Impl()) {}

Loader::~Loader() {
    cancel();
}

void Loader::start(const char* url, const char* destFileName) {
    cancel();

    NSString *nsUrl  = [NSString stringWithUTF8String:(url ? url : "")];
    NSString *nsName = [NSString stringWithUTF8String:(destFileName ? destFileName : "download.bin")];

    NSURL *u = [NSURL URLWithString:nsUrl];
    if (!u) {
        [FlowBridge emit:@(Signals::error) data:@"Invalid URL"];
        return;
    }

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    config.URLCache = nil;

    auto *delegate = [__FlowLoaderDelegate new];
    delegate.destFileName = nsName;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:delegate delegateQueue:[NSOperationQueue mainQueue]];
    delegate.session = session;

    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:u];
    delegate.task = task;

    impl_->delegate = delegate;

    // We'll let you know right away 0%
    [FlowBridge emit:@(Signals::progress) data:@(0.0)];

    [task resume];
}

void Loader::cancel() {
    if (impl_ && impl_->delegate) {
        [impl_->delegate cancel];
        impl_->delegate = nil;
    }
}

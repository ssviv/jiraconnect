#import "JMCTransportOperation.h"
#import "JMCMacros.h"
#import "JMCRequestQueue.h"
#import "JMCTransport.h"

@interface JMCTransportOperation ()

- (void)cancelItem;

@end

@implementation JMCTransportOperation

@synthesize delegate;
@synthesize request;

#pragma mark - Init / Dealloc Methods

+ (JMCTransportOperation *)operationWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    JMCTransportOperation *operation = [[JMCTransportOperation alloc] init];
    operation.request = request;
    operation.delegate = delegate;
    return operation;
}

- (void)dealloc {
    delegate = nil;
}

#pragma mark - NSOperation Methods

- (void)cancel {
    if (requestThread != nil) {
        [self performSelector:@selector(cancelOnRequestThread) onThread:requestThread withObject:nil waitUntilDone:YES];
    }
}

- (void)start {
    if (![self isCancelled]) {    
        [self willChangeValueForKey:@"isExecuting"];
        executing = YES;
        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [NSThread detachNewThreadSelector:@selector(connect) toTarget:self withObject:nil];    
        [self didChangeValueForKey:@"isExecuting"];
    }
    else {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self cancelItem];
        [self didChangeValueForKey:@"isFinished"];
    };
}

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    return executing; 
}

- (BOOL)isFinished {
    return finished;
}

#pragma mark - Private Helper Methods

- (void)cancelItem {
    NSString *requestId = [request valueForHTTPHeaderField:kJMCHeaderNameRequestId];
    [[JMCRequestQueue sharedInstance] updateItem:requestId sentStatus:JMCSentStatusRetry bumpNumAttemptsBy:1];
}

- (void)cancelOnRequestThread {
    [dataTask cancel];
    [self cancelItem];
}

- (void)connect {

    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        // Synchronize the cleanup call on the main thread in case
        // the task actually finishes at around the same time.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (backgroundTask != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
                [self cancel];
            }
        });
    }];
    
    @autoreleasepool {
        requestThread = [NSThread currentThread];
        
        __weak __typeof__(self) weakSelf = self;
        dataTask = [[NSURLSession sharedSession]
         dataTaskWithRequest:request
         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
             
             if (weakSelf == nil) {
                 return;
             }
             __typeof__(self) strongSelf = weakSelf;
             
             if (error == nil) {
                 strongSelf->statusCode = [(NSHTTPURLResponse *)response statusCode];
                 strongSelf->responseData = data;
                 
                 NSString *requestId = [strongSelf->request valueForHTTPHeaderField:kJMCHeaderNameRequestId];
                 NSString *responseString = [[NSString alloc] initWithBytes:[strongSelf->responseData bytes] length:[strongSelf->responseData length] encoding: NSUTF8StringEncoding];
                 if (strongSelf->statusCode < 300) {
                     // alert the delegate!
                     [strongSelf.delegate transportDidFinish:responseString requestId:requestId];
                     
                     // remove the request item from the queue
                     JMCRequestQueue *queue = [JMCRequestQueue sharedInstance];
                     [queue deleteItem:requestId];
                     JMCDLog(@"%@ Request succeeded & queued item is deleted. %@ ", strongSelf, requestId);
                 } else if (strongSelf->statusCode == 401) {
                     NSLog(@"Issue not created in JIRA because the autocreated user 'jiraconnectuser' does not have the 'Create Issue' permission on your project.\n Server Response: '%@'", responseString);
                     [strongSelf handleNetworkError:nil];
                 } else {
                     JMCDLog(@"%@ Request FAILED & queued item is not deleted. %@ %@",strongSelf, requestId, responseString);
                     [strongSelf handleNetworkError:nil];
                 }
             } else {
                 [strongSelf handleNetworkError:error];
             }
             
             [strongSelf willChangeValueForKey:@"isFinished"];
             [strongSelf willChangeValueForKey:@"isExecuting"];
             strongSelf->finished = YES;
             strongSelf->executing = NO;
             [strongSelf didChangeValueForKey:@"isExecuting"];
             [strongSelf didChangeValueForKey:@"isFinished"];
             
             strongSelf->requestThread = nil;
            
         }];
        [dataTask resume];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (backgroundTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
            backgroundTask = UIBackgroundTaskInvalid;
        }
    });

}

- (void)handleNetworkError:(NSError *)error {
    NSString *requestId = [request valueForHTTPHeaderField:kJMCHeaderNameRequestId];
    
    [[JMCRequestQueue sharedInstance] updateItem:requestId sentStatus:JMCSentStatusRetry bumpNumAttemptsBy:1];
    
    if ([self.delegate respondsToSelector:@selector(transportDidFinishWithError:statusCode:requestId:)]) {
        [self.delegate transportDidFinishWithError:error statusCode:(int)statusCode requestId:requestId];
    }
    
#ifdef JMC_DEBUG
    NSString *msg = @"";
    if ([error localizedDescription] != nil) {
        msg = [msg stringByAppendingFormat:@"%@.\n", [error localizedDescription]];
    }
    NSString *responseString = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding: NSUTF8StringEncoding];
    if (responseString) {
        msg = [msg stringByAppendingString:responseString];
    }
    JMCDLog(@"Request failed: %@ URL: %@, response code: %ld", msg, [[request.URL absoluteURL] description], statusCode);
#endif
}

@end

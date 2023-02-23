@import Foundation;
@import UIKit;

@interface JMCTransportOperation : NSOperation
{
@private
    BOOL finished;
    BOOL executing;
    NSInteger statusCode;
    NSData *responseData;
    NSThread *requestThread;
    NSURLSessionDataTask *dataTask;
    NSURLRequest *request;
    UIBackgroundTaskIdentifier backgroundTask;
}

@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, weak) id delegate;

+ (JMCTransportOperation *)operationWithRequest:(NSURLRequest *)request delegate:(id)delegate;

@end

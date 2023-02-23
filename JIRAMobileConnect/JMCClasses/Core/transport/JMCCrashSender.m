/**
   Copyright 2011 Atlassian Software

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
**/
#import "JMCMacros.h"
#import "JMCCrashSender.h"
#import "CrashReporter.h"
#import "JMC.h"
#import "JMCCrashTransport.h"
#import "JMCTransport.h"
#import "JMCIssueStore.h"
#import "JMCCreateIssueDelegate.h"
#import "JMCLocalization.h"
#import "UIApplication+JMC.h"

#define kJiraConnectAutoSubmitCrashes @"JiraConnectAutoSubmitCras"

@interface JMCCrashSender ()
@property (nonatomic, strong) JMCCrashTransport* transport;
@end

@implementation JMCCrashSender

- (id)init {
    self = [super init];
    if (self) {
        _transport = [[JMCCrashTransport alloc] init];
        _transport.delegate = [[JMCCreateIssueDelegate alloc] init];
    }
    return self;
}

- (void)promptThenMaybeSendCrashReports {
    if (![[CrashReporter sharedCrashReporter] hasPendingCrashReport]) {
        return;
    }

    if (![[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticallySendCrashReports]) {
        [self presentCrashFoundAlert];
    } else {
        [self sendCrashReports];
    }
}

- (void)presentCrashFoundAlert {
    NSString *title = JMCLocalizedString(@"CrashDataFoundTitle",
                                         @"Title showing in the alert box when crash report data has been found");
    NSString *description = JMCLocalizedString(@"CrashDataFoundDescription",
                                               @"Description explaining that crash data has been found and ask "
                                               @"the user if the data might be uplaoded to the developers server");
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:[NSString stringWithFormat:description, [[JMC sharedInstance] getAppName]]
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction =
        [UIAlertAction actionWithTitle:JMCLocalizedString(@"Yes", @"Yes")
         style:UIAlertActionStyleDefault
         handler:^(UIAlertAction * _Nonnull action) {
             [self sendCrashReports];
         }];
    UIAlertAction *alwaysAction =
        [UIAlertAction actionWithTitle:JMCLocalizedString(@"Always", @"Always")
         style:UIAlertActionStyleDefault
         handler:^(UIAlertAction * _Nonnull action) {
             [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAutomaticallySendCrashReports];
             [[NSUserDefaults standardUserDefaults] synchronize];
             [self sendCrashReports];
         }];
    UIAlertAction *noAction =
        [UIAlertAction actionWithTitle:JMCLocalizedString(@"No", @"No")
         style:UIAlertActionStyleCancel
         handler:^(UIAlertAction * _Nonnull action) {
             [[CrashReporter sharedCrashReporter] cleanCrashReports];
         }];
    [alertController addAction:yesAction];
    [alertController addAction:alwaysAction];
    [alertController addAction:noAction];
    [[UIApplication jmc_rootViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)sendCrashReports {
    if ([CrashReporter sharedCrashReporter] == nil) {
        return;
    }

    if (![[JMC sharedInstance] crashReportingIsEnabled])
    {
        // clean the reports
        [[CrashReporter sharedCrashReporter] cleanCrashReports];
        JMCALog(@"Crash reporting is disabled. No crash information will be sent.");
        return;
    }
    
    
    NSArray *reports = [[CrashReporter sharedCrashReporter] crashReports];
    // queue all the reports
    for (NSString *report in reports) {
        NSUInteger toIndex = [report length] > 500 ? 500 : [report length];
        [_transport send:@"Crash report"
             description:[[report substringToIndex:toIndex] stringByAppendingString:@"...\n(truncated)"]
             crashReport:report];
    }
    // clean the reports
    [[CrashReporter sharedCrashReporter] cleanCrashReports];
    // flush the queue to ensure they get sent
    [[JMC sharedInstance] flushRequestQueue];
}

@end

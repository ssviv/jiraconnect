/**
   Copyright 2015 Atlassian Software

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

#import "UIApplication+JMC.h"

@implementation UIApplication (JMC)

+ (UIViewController *)jmc_rootViewController {
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    NSAssert(rootViewController != nil, @"JIRA Mobile Connect Assert: "
             @"Key window must have a root view controller in order to present JIRA Mobile Connect alert controllers.");
    return rootViewController;
}

@end

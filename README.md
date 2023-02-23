# JIRA Mobile Connect for iOS
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Version](http://img.shields.io/cocoapods/v/JIRAMobileConnect.svg)](http://cocoapods.org/?q=JIRAMobileConnect) [![Platform](http://img.shields.io/cocoapods/p/JIRAMobileConnect.svg)]() [![License](http://img.shields.io/cocoapods/l/JIRAMobileConnect.svg)](https://bitbucket.org/atlassian/jiraconnect-apple/src/master/LICENSE.md)


JIRAMobileConnect is an iOS library that can be embedded into any iOS App to provide:

* **Real Time Crash Reporting** have users or testers submit crash reports directly to your JIRA instance
* **User or Tester Feedback** views for allowing users or testers to create a bug report within your app.
* **Rich Data Input** users can attach and annotate screenshots, leave a voice message, have their location sent
* **2-way Communication with Users** thank your users or testers for providing feedback on your App!


![](https://bitbucket.org/atlassian/jiraconnect-apple/wiki/JIRAMobileConnect.gif)


## Requirements

- iOS 8.0+
- Xcode 7.0+
- JIRA On Demand or JIRA instance with [JIRA Mobile Connect Plugin](https://plugins.atlassian.com/plugin/details/322837) installed

**Before distributing your software you must include the contents of the LICENCES file JIRAMobileConnect/JMCClasses/LICENSES somewhere within you app along with the License information that you can find lower in this document.**

## Installation
#### Carthage
*"[Carthage](https://github.com/Carthage/Carthage) is intended to be the simplest way to add frameworks to your Cocoa application."*
```bash
# Add to Cartfile:
git "https://bitbucket.org/atlassian/jiraconnect-apple.git" >= 1.2.6
```
#### CocoaPods
*"[CocoaPods](http://cocoapods.org) is the dependency manager for Swift and Objective-C Cocoa projects. It has over ten thousand libraries and can help you scale your projects elegantly."*
```ruby
# Add to Podfile:
pod "JIRAMobileConnect", "1.2.6"
```

#### Manually
Instructions coming soon.

## Configuration (iOS)
### Import JIRAMobileConnect into your `UIApplicationDelegate`
_Swift_
```swift
  import JIRAMobileConnect
```

_Objective-C_
```objc
  @import JIRAMobileConnect
```

### Configure the JMC shared instance
Add the source below and:

1. Replace the string @"https://connect.onjira.com" with the location of the JIRA instance you wish to connect to. NB: We highly recommend you use https (not http) to ensure secure communication between JMC and the User.
1. Replace the string @"NERDS" with the name of the project you wish to use for collecting feedback from users or testers
1. If the JIRA Mobile Connect plugin in JIRA has an API Key enabled, update the above apiKey parameter with the key for your project

_Swift_
```swift
func application(application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    JMC.sharedInstance().configureJiraConnect("https://connect.onjira.com/",
      projectKey: "NERDS", apiKey: "591451a6-bc59-4ca9-8840-b67f8c1e440f")

    return true
}
```

_Objective-C_
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[JMC sharedInstance]
     configureJiraConnect:@"https://connect.onjira.com/"
     projectKey:@"NERDS"
     apiKey:@"591451a6-bc59-4ca9-8840-b67f8c1e440f"];

     return YES;
}
```

## Configuration (JIRA)
The JIRA instance at the URL you configured above, will need to have:

1. The [JIRA Mobile Connect Plugin](https://plugins.atlassian.com/plugin/details/322837) installed
2. JIRA Mobile Connect enabled for your project:

    'Administer Project' --> *Your Project* --> Settings --> JIRA Mobile Connect

    ![Administration --> *Your Project* --> Settings --> JIRA Mobile Connect](https://bytebucket.org/atlassian/jiraconnect-ios/wiki/jira_settings.png)

3. Grant 'Create Issues' permission to jiraconnectuser.
Enabling the JIRA Mobile Connect plugin, for a project will automatically create a user in JIRA which will be used for creating all feedback and crash reports. This user must have the 'Create Issues' permission for the project you enabled the plugin on. In other words, the jiraconnectuser must be in a Group, Project Role or added explicitly to the 'Create Issues' permission in the permission scheme for your project. See Administration --> <PROJECT> --> Permissions

## Advanced Configuration

There are some other configuration options you can choose to set, if the defaults aren't what you require. To do this, explore the `[JMC sharedInstance] configureXXX]` methods.

**`JMCOptions`**
`JMCOptions` supports most of the advanced settings. This object gets passed to JMC when configure is called -- i.e. during `applicationDidFinishLaunching`.

`JMCOptions` lets you configure:

  * screenshots
  * voice recordings
  * location tracking
  * crash reporting
  * custom fields
  * the application's Console Log (NSLog output)
  * UIBarStyle for JMC Views
  * JIRA Project Key
  * JIRA instance URL
  * API Key

See `JMC.h` for all `JMCOptions` available.

**`JMCCustomDataSource`**
`JMCCustomDataSource` can be used to provide JIRA with extra data at runtime. The following is supported:

  * an extra attachment ( e.g. a database file )
  * customFields ( these get mapped by key name if a custom field of the same name exists for the JIRA project )
  * issue components to set ( e.g. iOS )
  * JIRA issue type ( maps the name of the issue-type to use in JIRA. e.g. a Crash --> Bug, Feedback --> Improvement )
  * notifierStartFrame ( `notifierEndFrame:` used to control where the notifier is animated from and to )

See `JMCCustomDataSource.h` for more information on these settings.


## Usage
### Trigger
Provide a trigger mechanism to allow users to invoke the Feedback view. This typically goes on the 'About' or 'Info' view. (Or, if you are feeling creative: add it to the Shake Gesture as is done in the sample Angry Nerds App!)

For example:
```objc
- (IBAction)triggerCreateIssueView
{
    [self presentModalViewController:[[JMC sharedInstance] viewController] animated:YES];
}
```

The view controller returned by JMC shared instance's `viewController` is designed to be presented modally. `[[JMC sharedInstance] viewController]` will return the 'Create Issue' view until the user creates feedback. From then on, the 'Issue Inbox' view is displayed, from where the user can tap the 'Create' icon to send more feedback.

If your info view controller is in a UINavigationController stack, then you can use the following snippet to show both the feedback view, and the history view.

If you would like your users to always access the Create Issue view, then you can do so by presenting the ``[[JMC sharedInstance] feedbackViewController]`` directly. e.g. the following will present just the create issue ViewController programatically:

```objc
- (IBAction)triggerCreateIssueView
{
    [self presentModalViewController:[[JMC sharedInstance] feedbackViewController] animated:YES];
}
```

Use `[[JMC sharedInstance] issuesViewController]` to simply present the inbox directly.

## Test & Debug
### Test Crash Reporting
You can test Crash Reporting by simply adding a `CFRelease(NULL);` statement somewhere in your code.

### Debug
If you wish to enable JMC debug logging in the console, then define the JMC_DEBUG=1 Preprocessor Macro for your build target. In Xcode: Targets --> <your target> --> Preprocessor Macross --> Debug --> + --> JMC_DEBUG=1 .

 ![JMC_DEBUG=1](https://bytebucket.org/atlassian/jiraconnect-ios/wiki/JMC_DEBUG.png)

## Notes
### Integration Notes
The notification view that slides up when a notification is received, is added to the application's `keyWindow`.

### Sample Apps
(These have not been updated yet.)

There are sample iPhone and iPad Apps in the jiraconnect-apple/samples directory.
AngryNerds and AngryNerds4iPad both demonstrate submitting feedback and crashes to the
[NERDS](https://connect.onjira.com/browse/NERDS) public project.

### JIRA Plugin
You will need access to a JIRA instance with the [JIRA Mobile Connect Plugin](https://plugins.atlassian.com/plugin/details/322837) installed. If you don't yet have access to a JIRA instance, you can use the NERDS project at http://connect.onjira.com for testing.

### Issue tracking
Use [http://connect.onjira.com/browse/CONNECT](http://connect.onjira.com/browse/CONNECT) to raise any issue with the JIRA Mobile Connect library.

## About
### Need Help?
If you have any questions regarding JIRA Mobile Connect, please ask on [Atlassian Answers](https://answers.atlassian.com/tags/jira-mobile-connect/).

### Contributors
* Nick Pellow [@niick](http://twitter.com/niick)
* Thomas Dohmke [@ashtom](http://twitter.com/ashtom)
* Stefan Saasen [@stefansaasen](http://twitter.com/stefansaasen)
* Shihab Hamid [@shihabhamid](http://twitter.com/shihabhamid)
* Erik Romijn [@erikpub](http://twitter.com/erikpub)
* Bindu Wavell [@binduwavell](http://twitter.com/binduwavell)
* Theodora Tse
* René Cacheaux [@rcachATX](http://twitter.com/rcachatx)

### License
Copyright 2011-2015 Atlassian Software.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use these files except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


### Third party Package - License - Copyright / Creator
plcrashreporter     MIT     Copyright (c) 2008-2009 [Plausible Labs Cooperative, Inc.]( http://code.google.com/p/plcrashreporter/)

crash-reporter              Copyright (c) 2009 Andreas Linde & Kent Sutherland.

UIImageCategories           Created by [Trevor Harmon.](http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/)

FMDB                MIT     Copyright (c) 2008 [Flying Meat Inc.](http://github.com/ccgus/fmdb)

Pod::Spec.new do |s|
  s.name         = "JIRAMobileConnect"
  s.version      = "1.2.6"
  s.summary      = "Enables JIRA to collect user feedback and real-time crash reports."

  s.description  = <<-DESC
                   JIRA Mobile Connect enables JIRA to collect user feedback and real-time crash reports for your mobile apps. Key features include:

                   * In-app User feedback- Get feedback from your mobile users or testers
                   * 2-way Communications -Developers can follow up with users or testers for additional feedback on your app or notify them that their issue has been resolved!
                   * Rich Data Collection-  Capture text and audio comments, annotated screenshots, and map any custom application data to fields in JIRA
                   DESC

  s.homepage     = "https://bitbucket.org/atlassian/jiraconnect-apple"
  s.license      = "Apache License, Version 2.0"
  s.authors          = { "Nick Pellow" => "http://twitter.com/niick", "Thomas Dohmke" => "http://twitter.com/ashtom", "Stefan Saasen" => "http://twitter.com/stefansaasen", "Shihab Hamid" => "http://twitter.com/shihabhamid", "Erik Romijn" => "http://twitter.com/erikpub", "Bindu Wavell" => "http://twitter.com/binduwavell", "Theodora Tse" => "" }

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ssviv/jiraconnect.git" }
  s.source_files = [
    "JIRAMobileConnect/JMCClasses/Base/**/*.{h,m,mm}",
    "JIRAMobileConnect/JMCClasses/Core/**/*.{h,m,mm}"
  ]
  s.public_header_files = [
    "JIRAMobileConnect/JMCClasses/Base/**/*.{h}",
    "JIRAMobileConnect/JMCClasses/Core/attachments/**/*.{h}",
    "JIRAMobileConnect/JMCClasses/Core/sketch/**/*.{h}",
    "JIRAMobileConnect/JMCClasses/Core/transport/**/*.{h}",
    "JIRAMobileConnect/JMCClasses/Core/model/**/*.{h}",
    "JIRAMobileConnect/JMCClasses/Core/queue/**/*.{h}",
    "JIRAMobileConnect/JMCClasses/Core/audio/**/*.{h}"
  ]
  s.resources = [
    "JIRAMobileConnect/JMCClasses/Base/**/*.{xib}",
    "JIRAMobileConnect/JMCClasses/Core/**/*.{xib}",
    "JIRAMobileConnect/JMCClasses/Resources/**/*.{png,bundle}"
  ]
  s.frameworks = "CFNetwork", "SystemConfiguration", "MobileCoreServices", "CoreGraphics", "AVFoundation", "CoreLocation"
  s.libraries = "sqlite3"
  s.vendored_frameworks = "JIRAMobileConnect/JMCClasses/Libraries/CrashReporter.framework"

  s.requires_arc = true

end

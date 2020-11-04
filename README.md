# RLT iOS SDK

## Setup

### Podfile

```ruby
use_frameworks!
pod 'RLT-iOS', :git => "git@github.com:ruby-light/RLT-iOS.git"
```

### Manually

Drag the `RLT-iOS/RLT-iOS` folder into your project

## Usage

### Objective-C

```objectivec
RLTInitConfig *initConfig = [[RLTInitConfig alloc] init];
initConfig.devicePropertyConfig = [[[[[[[[[[[RLTDevicePropertyConfig alloc] init]
        trackPlatform]
        trackManufacturer]
        trackBrand]
        trackModel]
        trackOsVersion]
        trackAppVersion]
        trackCountry]
        trackCarrier]
        trackLanguage];
initConfig.serverUrl = @"https://stats.mydomain.com";
initConfig.enableStartAppEvent = YES;
initConfig.enableSessionTracking = YES;
[RLT initializeWithApiKey:@"<API_KEY>" initConfig:initConfig];

[RLT logUserProperties:[[RLTUserProperties instance] set:@"male" forKey:@"gender"]];
[RLT setUserId:@"123123-341231"];
[RLT logEvent:@"StartConversation" eventProperties:[[[RLTEventProperties instance] set:@"private" forKey:@"type"] set:@"foo" forKey:@"bar"]];
[RLT logEvent:@"EndConversation"];
[RLT flush];
```

### Swift

```swift
let initConfig = RLTInitConfig()
initConfig.devicePropertyConfig = RLTDevicePropertyConfig().trackPlatform().trackManufacturer().trackBrand().trackModel().trackOsVersion().trackAppVersion().trackCountry().trackCarrier().trackLanguage()
initConfig.serverUrl = "https://stats.mydomain.com"
initConfig.enableStartAppEvent = true
initConfig.enableSessionTracking = true
self.rlt = RLT.initialize(withApiKey: "<API_KEY>", initConfig: initConfig)

RLT.logUserProperties(RLTUserProperties.instance().set("male", forKey: "gender"))
RLT.setUserId("123123-341231")
RLT.logEvent("StartConversation", eventProperties: RLTEventProperties.instance().set("private", forKey: "type").set("foo", forKey: "bar"))
RLT.logEvent("EndConversation")
RLT.flush()
```

## License

`RLT-iOS` is distributed under the terms and conditions of the [MIT license](https://github.com/ruby-light/RLT-iOS/blob/master/LICENSE).

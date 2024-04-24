# AnonymousChat

A simple iOS nearby chat app which support text, image and video

https://github.com/tk930528/COMP-7506---AnonymousChat/assets/168002868/e7fcacae-f764-494f-8a7f-814ff2572922

https://github.com/tk930528/COMP-7506---AnonymousChat/assets/168002868/62f748f7-b9c9-466c-ae3c-4c8a7df83189

## Tech Stacks
* Mutlipeer connectivity
* Combine
* SwiftUI

## Getting Started

### Dependencies

* SwiftyChat
* KingFisher

### Installing

* Clone project
```
git clone https://github.com/tk930528/COMP-7506---AnonymousChat.git
```
* Remember to use xcode 14 or above version
* Install simulator dependencies with iOS 15 or above
* All dependencies would be installed automatically by ```Swift Package Manager``` after you open the project

### Executing application

#### Build Manually
1. Click Project
2. Select target ```AnonymousChat```
3. Click ```Signing & Capabilities```
4. Click ```Automatically manage signing``` to let apple create a signing certifcate for you
5. Signin your own apple id and select personal team
6. Change the bundle id if needed
7. Select a simulator
8. Run the project by ```Command + R```

#### Build with termainal (not recommand)
1. Repeat 1 to 5 from manual steps
2. Open terminal
3. Run ```xcodebuild build -project <Your Project Directory>/AnonymousChat.xcodeproj -scheme AnonymousChat -allowProvisioningUpdates``` to build the .App in xcode
4. Run ```xcrun simctl boot "iPhone 15 Pro"``` to open a simulator, you could choose any installed devices as you like
5. Run ```xcrun simctl launch booted <Bundle id that you changed>```

## Authors

Karl Tai

## Version History

* v1.0.0
    * Initialization 

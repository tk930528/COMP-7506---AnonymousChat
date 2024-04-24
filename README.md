# AnonymousChat

A simple iOS nearby chat app that supports text, images, and videos.

https://github.com/tk930528/COMP-7506---AnonymousChat/assets/168002868/e7fcacae-f764-494f-8a7f-814ff2572922

https://github.com/tk930528/COMP-7506---AnonymousChat/assets/168002868/62f748f7-b9c9-466c-ae3c-4c8a7df83189

## Tech Stacks
* Mutlipeer Connectivity
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
* Ensure you use Xcode version 15.2 or above.
* Ensure simulator dependencies are compatible with iOS 17.2 or above.
* All dependencies will be installed automatically by the ```Swift Package Manager``` once you open the project.

### Executing application

#### Build Manually
1. Click Project.
2. Select target ```AnonymousChat```.
3. Click on ```Signing & Capabilities```.
4. Click on ```Automatically manage signing``` to allow Apple to create a signing certificate for you.
5. Sign in with your Apple ID and select a personal team.
6. Change the bundle ID if necessary.
7. Select a simulator.
8. Run the project by ```Command + R```.

#### Build with termainal (Not recommanded)
1. Repeat steps 1 to 5 from the manual instructions.
2. Open terminal.
3. Run ```xcodebuild build -project <Your Project Directory>/AnonymousChat.xcodeproj -scheme AnonymousChat -allowProvisioningUpdates``` to build the .App file in xcode.
4. Run ```xcrun simctl boot "iPhone 15 Pro"``` to open a simulator, you can choose any installed device as you like.
5. Run ```xcrun simctl launch booted <Bundle ID that you changed>```.

## Authors

Karl Tai

## Version History

* v1.0.0
    * Initialization 

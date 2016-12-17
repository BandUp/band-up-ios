#BandUp iOS Client
## Getting Started
To get started install CocoaPods onto your machine.

### Install CocoaPods
Install CocoaPods onto your computer with

```sudo gem install cocoapods```

### Install Packages for the Project
To install the packages the project uses, go to the root of the project and run the following command.

```pod install --verbose```

This can take a while, as it will be fetching a repo from GitHub that is approximately 1 GiB in size.

### Open the Xcode Project
After running the ```pod install --verbose``` command, the ```band-up-ios.xcworkspace``` file will be created that includes the Pods packages. Open this file if you want to launch the project. If you open the ```band-up-ios.xcodeproj``` the Pods will not be included and the build will fail.

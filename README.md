# Socure Device Risk SDK React Native Bridge

The Socure Device Risk SDK React Native bridge provides Reach developers with the ability to call the Socure Device Risk SDK, either the [Android](https://github.com/socure-inc/socure-sigmadevice-sdk-android) or [iOS](https://github.com/socure-inc/socure-sigmadevice-sdk-ios) native library variants, through React.

This guide covers the integration within React, as well as React Native implementation on iOS and Android.

**Minimum Requirements**
<br>iOS 12.0 and above
<br>Android SDK version 32 and above, Kotlin version 1.6.0 and above

## Introduction
Please read the documentation on either the [Android](https://github.com/socure-inc/socure-sigmadevice-sdk-android) or [iOS](https://github.com/socure-inc/socure-sigmadevice-sdk-ios) native library variants to understand how the Device Risk SDK works.

## Installation

Please follow the instructions below to add this wrapper library to your project. Alternatively, you can use this [sample app](https://github.com/socure-inc/socure-sigmadevice-demo-app-react-native) as a starting point.

Add the following dependency to `package.json`:

```
"dependencies":{
	....,
	"react-native-device-risk": "https://github.com/socure-inc/socure-sigmadevice-wrapper-react-native#1.2.1"
}
```

### Android
**Step 1: Configuration**
<br>Please ensure that the *compikeSDKVersion* is set to 32 (or above)

**Step 2: Synchronize your gradle projects**
<br>The Android side of the Bridge should be ready to run.

Note: If pulling from Maven, implement the below)
```
buildscript {
	…………..
	dependencies {
		……………………
		classpath ‘com.github.dcendents:android-maven-gradle-plugin:1.5’
	}
}
```

(NOT IN THE `buildscript` code block above. allprojects is a sibling to build script)
```
You will receive a username and token from Socure
Place these variables in you gradle.properties file inside your Android project

allprojects {
    repositories {
        …….

        maven {
            url “https://jitpack.io”
        }
    }
}
```

* Ensure `Kotlin` plugin is added in the `dependencies` section:
```
buildscript {

                .....

               dependencies {

                  .....

                  classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:x.x.x"

               }

           }
```
> **Note:** Socure has tested the build with plugin version 1.6.0.

**Step 3:**

In the main module `(<root project dir>/android/app/build.gradle)` add the below dependency
in `dependencies {}` section:

```
dependencies {
   .....
   implementation "org.jetbrains.kotlin:kotlin-stdlib:x.x.x"
   .....
}
```

> **Note:** Socure has tested the build with plugin version 1.6.0.

**Step 4:**

In the `(<root project dir>/android/gradle.properties)` file add the following:

```
username=Socure
authToken=Socure
```

Build and run:

* Run `yarn install`.
* Run `react-native run-android` from the root folder.

### iOS

**Step 0: Install cocoapods-user-defined-build-types**

Since the Socure Document Verification SDK is an XCFramework, Cocoapods doesn’t easily allow dynamic frameworks to intermingle with static libraries. This gem modifies Cocoapods to allow both to exist at the same time. Follow the instructions over at [https://github.com/joncardasis/cocoapods-user-defined-build-types](https://github.com/joncardasis/cocoapods-user-defined-build-types)

**Step 1: Install Socure SDK React Native Bridge using CocoaPods (recommended)**

Before your `target`, add the following:

```
plugin 'cocoapods-user-defined-build-types'
enable_user_defined_build_types!
```

and inside your `target`, add the corresponding `pod` lines

```
use_frameworks!

  pod 'SocureDeviceRisk', :build_type => :dynamic_framework
```

Update your pods from the terminal
```
pod install
```

You can also copy the folder `react-native-device-risk` and add it along with your other React Native pods.

**Step 2: Add appropriate permissions for the services you want DeviceRisk SDK to use**

This is explained in more detail in the [native iOS library’s documentation](https://developer.socure.com/docs/sdks/sigma-device/ios-sdk/ios-overview#deviceriskdatasources)

**Step 3:**

* Run `react-native run-ios`.

## Usage

All the API methods are available via `RnDeviceRisk` module. You can import the module in your code as shown below
```
import RnDeviceRisk from 'react-native-device-risk';
```

### setTracker

```
await RnDeviceRisk.setTracker(<SDK Key>, <Array of DeviceRiskDataSources>)
```

Where the `<SDK Key>` input parameter is your SDK key procured from the Socure admin dashboard. `DeviceRiskDataSources` is an enum that encompasses all of the different device features and services we currently support. The `setTracker` method accepts  an array of `DeviceRiskDataSources` to determine the data sources that the SDK has to collect the data from.

### DeviceRiskDataSources

The following is the list of various data source options provided by the SDK

```
    case device
    case accelerometer
    case motion
    case magnetometer
    case locale
    case location
    case advertising
    case pedometer
    case network
    case accessibility
```

Say you want to collect data about the user device, network and locale, you will call `setTracker` as follows:

```
RnDeviceRisk.setTracker("your-sdk-key-goes-here", ["device", "network", "locale"])
```

Alternatively, if you would like to collect data from all the sources, the implementation looks as shown below:

```
RnDeviceRisk.setTracker("your-sdk-key-goes-here", Object.keys(RnDeviceRisk.getConstants()))
```

### sendData

`sendData` call sends a request with the data collected from the device to Socure’s backend. The request upon success returns with a response consisting of a unique string (`DeviceSessionID`) for the device.

Call `RnDeviceRisk.sendData()`. It returns a “promise” object which can then be managed with an `async/await` call.

The following code snippet shows an example usage of `sendData`:

```
RnDeviceRisk.sendData().then((res) => {
      console.log('DeviceSessionID', res);
    });
```

## Example
You can checkout the example app from [here](https://github.com/socure-inc/socure-sigmadevice-demo-app-react-native). The file `App.js` shows the JS function calls used and how to ultimately retrieve the Device Risk Session ID.

## FAQ's
Make sure you are using the latest version

- Getting 'RnDeviceRisk' not found or doesn't exist?
    Android: Make sure you added the module into the MainApplication class
        into getPackages function `packages.add(new DeviceRiskPackage());`

- Setting trackers throws an error they are not valid? (NoSuchFieldError) \n
    You can use the `getConstants` method to know the real name of the providers.
    Because at the native level, Android and iOS handle differently the string enum convertion. Make sure to send the right one for each platform.

- Lib isn't working properly?
    Make sure you call `setTracker` using the right token and later call `sendData`

- Getting IllegalArgumentException or similar when calling function?
    This are the argument types of each function. Check if you are sending the right one.

    `setTracker (socureKey: String, providers: [String])`

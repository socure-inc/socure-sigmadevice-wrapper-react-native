# Socure Device Risk SDK React Native Bridge

The Socure Device Risk SDK React Native bridge provides Reach developers with the ability to call the Socure Device Risk SDK, either the [Android](https://github.com/socure-inc/socure-sigmadevice-sdk-android) or [iOS](https://github.com/socure-inc/socure-sigmadevice-sdk-ios) native library variants, through React.

This guide covers the integration within React, as well as React Native implementation on iOS and Android.

**Minimum Requirements**
iOS 13 and above
Android SDK version 33 and above

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
**Step 1: Open the module level build.gradle for the main project module and inside of the defaultConfig section, set the minSdkVersion to 33**

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
> **Note:** Socure has tested the build with plugin version 1.7.0.

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

> **Note:** Socure has tested the build with plugin version 1.7.0.

Build and run:

* Run `yarn install`.
* Run `react-native run-android` from the root folder.

### iOS

**Step 1: Install Socure SDK React Native Bridge using CocoaPods (recommended)**

Inside your `target`, add the corresponding `pod` lines

```
use_frameworks!

  pod 'SocureDeviceRisk'
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

## Configuration and usage
For instructions on how to configure the SDK, see the [React Native documentation](https://developer.socure.com/docs/sdks/sigma-device/react/react-overview) on DevHub.

## Example
You can checkout the example app from [here](https://github.com/socure-inc/socure-sigmadevice-demo-app-react-native). The file `App.js` shows the JS function calls used and how to ultimately retrieve the Device Risk Session ID.

<h2>Wildcard iOS SDK</h2>

Public SDK documents can be found [here](http://www.trywildcard.com/docs/ios-sdk).

<h3>Building</h3>

All targets are included in **WildcardSDKProject.xcodeproj**

<h4>Project Schemes</h4>

<h5>WildcardSDK</h5>

The Core SDK as an iOS Framework. You normally should not have to select this scheme directly.

<h5>WildcardSDKTestApp</h5>

This should be the scheme primarily used for developerment. This depends on the Core SDK and serves as a test bench to run a simple application to test the SDK code. 

This scheme also includes the **WildcardSDKTests** target which includes all the tests for the SDK. 

<h5>Framework</h5>

The Framework scheme should be used when you are ready to package up the SDK and get it ready for distribution. 

1. Select the Framework scheme (Bullseye icon) and choose iOS Device
2. Clean + Build
3. A custom script is executed which produces packaged Framework files which need to be uploaded to S3. Both files should exist on your desktop after the build is done.

*WildcardSDK.framework.tar.gz*

This is a "fat" framework distribution that developers may use for Simulator + Devices. 

*WildcardSDK_iphoneos.framework.tar.gz*

This is a framework distribution only built for Devices. 

<h3>Demo App</h3>

This repo also contains a demo iOS Application (WCRedditCards) that is used to demonstrate the SDK.

When the SDK is updated, the demo app should also be updated to use the latest code.

1. Use the official [installation steps](http://www.trywildcard.com/docs/ios-sdk/installing) to install the latest SDK into the project. 
2. Run the project, and just sanity check that it still works.
3. Inside the repo 


<h3>Uploading</h3>

*Internal Wildcard Use Only*






<h3>Future</h3>

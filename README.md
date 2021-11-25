# pin_lock

All apps are unique in the look and feel of their local authentication layer: lock screens and pincode setup flows are a great canvas for expressing your app's personality. 

However, at the core of most implemetation are the same principles: the app should show its content only to the authorized users. 

The aim of the pin lock package is to provide a solid implemetation of the underlying logic on Android and iOS, while giving the developers all of the freedom to build unique interfaces for interacting with this logic. 

### Table of contents
- [Features](#features)
- [Permissions and integration](#permissions-and-integration)
- [Usage](#usage)

## Features

#### Locking functionality
* ✅  App is protected with a pin code when opened (if pin code is enabled)
* ✅  Lock the app after it has been in the background for a specified period of time
* ✅  Unlock with a (numeric) pincode
* ✅  Unlock with native biometric authentication (fingerprint, faceID, iris)
* ✅  Block authentication attempts after a specified number of incorrect pin inputs for a specified amount of time
* ✅  Optionally hide the app preview (thumbnail) when switching between the apps (multitasking)
	* ✅ iOS: Add an custom placeholder asset to be shown in the App Switcher
* ✅  Support for multiple accounts using the same device

#### Locking setup 
* ✅  Implements standard pin authentication flows:
	* ✅  enabling pin (with required re-entering for confirmation)
	* ✅  disabling pin (requires current pin before disabling)
	* ✅  changing pin (requires current pin, new pin and new pin confirmation)

#### Planned
* ⬜️ TODO: Hiding the app preview only if pin code is enabled.
* ⬜️ TODO: Refine blocking authentication after `x` incorrect pin inputs
	* ⬜️ TODO: Make pin input `disabled` when authentication is blocked
	* ⬜️ TODO: Pass the duration for which the authentication is blocked to the UI
* ⬜️ TODO: Implement an optional secondary pin (like a safety question) that enables unlocking the app if the primary pin is forgotten
* ⬜️ TODO: Add an optional logout button to the locked screen, enabling the user to change the account without uninstalling the app.

## Permissions and integration

### iOS
If you want to make use of biometric authentication, add `NSFaceIDUsageDescription` to your app's `Info.plist` file.

```plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<... other stuff ...>
	<key>NSFaceIDUsageDescription</key>
	<string>You can use biometric authentication to secure access to your data.</string>
</dict>
</plist>
```
### Android
Make sure that your main activity extends `FlutterFragmentActivity`, e.g.:
```kotlin
package ...your package name...

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
```

### `WidgetsBindingObserver`
To enable automatic locking of the app after it has been in the background for a specified amount of time, you need to let the `pin_lock` plugin observe app lifecycle. In the root widget of the part of the app that you want to be lockable (e.g., you might not want to include your onboarding or login screen) add the following:

```dart
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(authenticatorInstance);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(authenticatorInstance);
    super.dispose();
  }
```
In practice, the best place to register `Authenticator` as an observer would be right above the `AuthenticatorWidget`

## Usage
Most interaction happens with three main plugin components:
  - global `Authenticator` class which is the brain of the operation and through which you can configure most of the preferences for how the local authentication is implemented.
  - `AuthenticatorWidget` which is the root of the secured part of the app and through which you will configure the UI of your lock screen
  - `AuthenticatonSetupWidget` that accepts descriptions of what different stages of authentication setup should look like. It is meant to be inserted into the settings/preferences section of your app, and can be made to fit exactly with you app's style.

### Setup `Authenticator`

The first thing to do when integrating the package is to create a globally accessible (singleton) instance of the `Authenticator`. There are two convenience initializers you can use. The `PinLock.baseAuthenticator()` is a quick way to get an instance with all the default settings. If you want to change any of the default settings or use your own implementation of any of the components of it, `PinLock.authenticatorInstance()` factory method allows you to create it.
```dart
  authenticator = await PinLock.baseAuthenticator('1');
  // or
  authenticator = await PinLock.authenticatorInstance(userId: '1', ...the rest of your configuration here...);
```
`userId` is a `String` parameter that enables multiple users to use the app with different pin codes. Here you would provide a value that you can guarantee is unique for your users (like their username or user id). 
If you do not want to support multiple accounts on a single device, you can provide a hard coded string value instead. 

> ⚠️ If you hard-code the `userId`, you need to **make sure you disable pin authentication on logout**, otherwise your next user will not be to use the app on the same device without reinstalling it.

After completing this step, your app has an instance of `Authenticator` that knows what the logic of your app's locking behavior and knows where to store this data.

### Setup `AuthenticatorWidget`

`AuthenticatorWidget` is the root of the secured part of your application. Normally, you would want it to encompass your entire application except for onboarding, sign in and sign up flows (at which point you also do not know the identity of your user, meaning that you cannot provide a reliable `userId`).

The core parameters of `AuthenticatorWidget` are:
- `child` - which is you application's normal widget tree
- `pinNodeBuilder` - which is a builder function through which you provide information about what the individual input fields should look like, given the `state` that they are in
- `lockScreenBuilder` - which is another builder function through which you describe what you want your whole pin input screen to look like (given the `LockScreenConfiguration`)

If you want the app to be locked (show the lock screen) after a specified amount of time of it being in the background, don't forget to include [`WidgetsBindingObserver` step](#WidgetsBindingObserver).

Upon completing this step, your app knows which part of your app is protected by the pin code and what the lock screen of the app should look like. 
### Setup `AuthenticatonSetupWidget`

The final step involves describing what the user interface looks like for a user who is trying to enable, disable, or change their pin code.

`AuthenticationSetupWidget` is meant to be placed in the settings or preferences screen of your app. It requires you to set up builders for different flows of interaction with the pin code.

* `overviewBuilder` is the first thing your user sees when getting to settings, before they have done any action. It contains information about whether the pin code and biometric authentication are currently enabled.
* `enablingWidget`, `disablingWidget` and `changingWidget` should return widgets that describe what the respective screens should look like. The `Configuration` parameter of builders aims to contain all of the information you need to display the correct state to your user. Properties such as `canSubmitChange` can be used to enable or disable buttons, and `error` property can be mapped to a more descriptive, localized text that conveys to your user exactly what went wrong and how to fix it.

You can use `AuthenticationSetupWidget` in multiple places in your app. For example, this widget can be added as a child of a `ListTile` of your settings screen, where you'd only provide the `overviewBuilder` (and return a `Container` from all other builders). This way you can preview the current state of pin code authentication in your app's general settings. Clicking on this tile could open a new screen in which you could have another `AuthenticationSetupWidget` with all off the builders describing your app's pin setup flow.

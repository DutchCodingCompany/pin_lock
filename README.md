# pin_lock

**pin_lock** package takes care of the implementation of securing the app with a pin code, so that the developer can focus on building the app-specific UI without thinking about the implementation details, which are similar for all apps.

## Features
* ✅  Locks the screen of the app when the app is first opened if pin authentication is enabled
* ✅  Locks the screen after a the app has been in the background for a specified period of time
* ✅  Unlock with a (numeric) pincode
* ✅  Unlock with native biometric authentication (fingerprint, faceID, iris)
* ✅  Implements standard pin authentication flows:
	* ✅  enabling pin (with confirmation pin)
	* ✅  disabling pin 
	* ✅  changing pin 
* ✅  Hide the app screen when switching between the apps 
	* ⬜️ TODO: Hide the app preview only when pin authentication is enabled
	* ⬜️ TODO: Make what is displayed in the preview customizable (currently it's a black screen for Android and a white/black screen depending on the system theme for iOS)
* ✅  Support for multiple accounts using the same device
* ⬜️ TODO: Block pin input retries after a specified amount of failed attempts for a specified amount of time
* ⬜️ TODO: Implement a secondary pin (like a safety question) that enables unlocking the app if the primary pin is forgotten
	
### Known issues
* ⬜️ App switcher overlay gets triggered when doing biometric authentication, hiding the lock screen

## Permissions and integration
// TODO: Describe which permissions are needed
// TODO: WidgetsBindingObserver explanation

## Usage
// TODO: Usage + philosopy behind builders and configurations

## 0.1.0

- [BREAKING] Change `maxRetries` to `maxTries`. #16
- Fixed bug when clearing input on error focus of android keyboard was lost. #17
- Fixed bug preventing calling `_checkInitialLockStatus` twice and added `isCorrectPin` method to authenticator for verifying pin without unlocking. #14

## 0.0.4

- reverted removing of safe-calls on overlays. They are only for flutter >= 3.7.0.
- Changed flutter sdk limit from >= 1.20.0 to  >= 3.0.0

## 0.0.3

- Changed `lint` package to `flutter_lints` #12
- Exposed BiometricAvailability `Available` & `Unavailable` state. #11
- Update `local_auth` package to 2.1.3 #9
- Fixed crash when returning Unit through MethodChannel. #5

## 0.0.1+5

Fixed static analysis

## 0.0.1+4

Updated dependencies:
`dartz 0.10.0 => 0.10.1`
`flutter_bloc 7.0.0 => 8.0.1`
`equatable 2.0.0 => 2.0.3`
`build_runner 1.12.2 => 2.1.7`
`mockito 5.0.3 => 5.0.17`

## 0.0.1+3

Replaced jcenter with mavenCentral

## 0.0.1+2

Code formatted with `flutter format .`

## 0.0.1+1

Initial release to pub.dev

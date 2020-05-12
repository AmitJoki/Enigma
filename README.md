<a href="https://github.com/Solido/awesome-flutter">
   <img alt="Awesome Flutter" src="https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square" />
</a>

# Enigma

Enigma - A minimalist, locked-down one-to-one chat app.

## Usage

* [Flutter - Get Started](https://flutter.dev/docs/get-started/install)
* Since this is a Firebase dependent project, create a Firebase Project and enable
  * Firebase Phone Authentication (for authentication)
  * Cloud Firestore (not Realtime Database)
  * Firebase Storage (for storing images)
  * Firebase In-App Messaging (for custom messages)
* After enabling the above features, download the `google-services.json` and paste it in `android/app` folder.
* Do `flutter packages get` to get the packages.
* Use a device or an emulator and run `flutter run`.

## Notifications

1. Enable FCM in your Firebase Console.
2. Notifications use Cloud Functions. Copy the `functions` directory to the root of your project.
3. Do `firebase deploy --only functions` You need to have `firebase-cli` installed for this command to execute.

## Screenshots

![Screenshot #1](https://i.imgur.com/j6K1iKg.jpg)


## Firebase Rules for Storage and Cloud Firestore

I've used the following basic rule

```
allow read, write: if request.auth.uid != null;
```

but you can be more restrictive if you so wish. For more info - [Get Started on Writing Rules](https://firebase.google.com/docs/firestore/security/get-started#writing_rules)

<a href='https://play.google.com/store/apps/details?id=com.enigma.amitjoki&pcampaignid=MKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png'/></a>

<small>Google Play and the Google Play logo are trademarks of Google LLC.</small>


## Features

**Authentication:** Passcode authentication is enabled which is needed to unlock hidden and locked chats. If your device supports fingerprint authentication, then you can use it as well.

**End-To-End Encryption:** Your messages are encrypted right from the moment you send it. This makes sure that only the recipient receives the message and <b>NO ONE ELSE.</b>

**Hide Chats:** You can hide chats to protect against prying eyes. YOU will have to authorize to unhide the chats.

**Lock Chats:** Hidden chats not secure enough? Lock individual chats which only open after YOU have authorized it.

**End Conversations:** Once you're done with a conversation, you can choose to end it, by swiping your friend's message from left to right. Doing so will delete all the conversation up until that message. 

**Save messages:** Double tap on any message to save it locally. Saved messages can be viewed by swiping right to left on the chat screen.

**No pesky notifications:** We do not believe in keeping users addicted to our app by frequent notifications. Chat when you feel like it. We do not bother you with notifications.

**No forwarding:** Enigma is developed to be an intimate one-to-one chat application. There's no option for forwarding messages. Hence no fake news.

**Beautiful, minimal UI:** The UI is uncluttered and beautiful. Gestures are used to make it pragmatic instead of using additional screen space.

**Less than 10 MB:** All the above features are tucked under a measely < 10 MB APK Size.

## Acknowledgement

Passcode Widget: https://github.com/xPutnikx/flutter-passcode [Apache 2.0 License](https://github.com/xPutnikx/flutter-passcode/blob/master/LICENSE)

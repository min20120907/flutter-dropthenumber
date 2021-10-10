# dropthenumber
A minigame written in flutter.

## Supported Platforms
- [x] iOS 3rd party software  
- [x] Android APK  
- [x] Android AAB  
- [x] Android Google Play  
- [ ] Chrome  

## Game features
1. The mute buttons appear on the main screen and on the game play screen
2. The volume adjustment buttons appear on the main screen
3. Pause button
4. Horiznotal superpower (can be used once every 2 minutes) every time you enable this function, the last square of each row will be remove
5. Vertical superpower (can be used once every 2 minutes) every time you enable this function, all the squares in the highest track will be remove
6. Reset button after the game is over, reset the layout, time, and automatically start playing
7. The Quit buttons appear on the main screen and when the game is over, click to exit the game
8. The back to main screen button appears in the lower left corner when the game is over 

## How to run
1. Generate upload-keystore.jks for application signature. [(flutter document)](https://flutter.dev/docs/deployment/android#create-an-upload-keystore) <br />
In Linux or Mac: ```keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload``` <br />
In Wnidows: ```keytool -genkey -v -keystore c:\Users\<USER_NAME>\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload``` <br />

2. Update the path to your signature file. <br />
update the ```storeFile=/home/<USER_NAME>/upload-keystore.jks in <PROJECT_PATH>/android/key.properties``` <br />

3. Run now! For more information please check [flutter document](https://flutter.dev/docs/reference/flutter-cli). <br />
flutter run

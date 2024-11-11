Steps for the Setup
*******************************

*use flutter version 3.22.2 and dart version - 3.4.3*

1. Set your API Key inside the `.env` file: for  OPEN_AI_API_KEY, GEMINI_AI_API_KEY, STABILITY_AI_API_KEY

2. If you're willing to change the environment variable name, then you should change it as well inside the `lib/env/env.dart`, otherwise if you're not changing it, pass directly to the next step.

3. Run `flutter pub get` to install dependencies for Flutter.

4. Run `dart run build_runner build` to generate necessary code.

*Skip to step 8 as Step 5, 6, 7 are only for macOS users, as macOS needs to request a specific entitlement in order to access the network.

5. Check the `DebugProfile.entitlements` and `Release.entitlements` files in the `macos/Runner` folder to ensure the following lines are added:

   <key>com.apple.security.network.client</key>
   <true/>

6. Make sure to change the key value from true to false in `DebugProfile.entitlements` 
    <key>com.apple.security.app-sandbox</key>
	<false/>

7. Add the following key-value pair lines in the Info.plist file present in the `macos/Runner` folder:

  <string>NSApplication</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>We need access to your photo library to select images.</string>
	<key>NSCameraUsageDescription</key>
	<string>We need access to your camera for taking photos.</string>
	<key>NSMicrophoneUsageDescription</key>
	<string>We need access to your microphone for audio input.</string>

8. Run the applications from your IDE, alternatively, you can use below commands to run it from terminal.

9. To run the Flutter application, execute the following commands based on your target platform:

    For Chrome (web) - For chrome we need to run it from terminal only as we have to disable the web security because it produces CORS error for opening image.
    *********************
    #In Debug mode: 

        flutter run -d chrome --web-browser-flag "--disable-web-security" --web-port 5555 (We need to specify port here as chrome and other browsers uses local storage, this is helpful to persist the search history)
    
    #In Release mode:

        flutter run -d chrome --web-browser-flag "--disable-web-security" --web-port 5555 --release

    For macOS 
    *********************
    #In Debug mode

        flutter run -d macOS

    #In Release mode:

        flutter run -d macOS --release        





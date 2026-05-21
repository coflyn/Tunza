# Tunza Audio Player

![License](https://img.shields.io/badge/license-GPLv3-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)

Tunza is a modern, feature-rich local audio player built with Flutter. It focuses on providing a premium listening experience with a clean user interface, seamless background playback, and smart track management.

## Features

- Local Audio Scanning: Automatically scans and loads audio files from the device storage.
- Smart Playlists: Automatically tracks and organizes music into Favorites, Recently Added, Last Played, and Most Played lists.
- Background Playback: Uninterrupted music playback with system notification controls.
- Seamless Navigation: Smooth swipable tabs to navigate through Library, Playlists, Artists, and Albums.
- Fullscreen Player: Includes synchronized scrolling lyrics, a visualizer, and intuitive media controls.
- Search Functionality: Easily find tracks, artists, or albums within the local library.

## Project Structure

The main entry point for the application is `lib/main.dart`, which initializes the background audio session, handles permissions, and sets up the root user interface.

State management and audio playback are handled centrally using `just_audio` and `just_audio_background`.

## Setup and Installation

1. Ensure you have Flutter installed and set up on your machine.
2. Clone this repository to your local machine.
3. Run `flutter pub get` to install all required dependencies.
4. Run `flutter run` to launch the application on a connected device or emulator.

## Dependencies

- just_audio: Core audio playback functionality.
- just_audio_background: Background playback and system notifications.
- on_audio_query: Querying and retrieving local audio files and metadata.
- permission_handler: Managing runtime storage permissions.
- shared_preferences: Persisting user data like play counts and favorites.

## Build Requirements

- Android: Requires minSdk 21 and targetSdk 33 or higher.
- iOS: Requires iOS 11.0 or higher. Note that Swift Package Manager adoption may be required for certain plugins in future updates.

## Development Notes

When running on Android 13 or higher, ensure that the application is granted the `READ_MEDIA_AUDIO` permission for proper library scanning. The application uses `content://` URIs to support scoped storage natively.

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0). See the [LICENSE](LICENSE) file for more details.

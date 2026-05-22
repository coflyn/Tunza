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
- Fullscreen Player: Includes a visualizer, intuitive media controls, and synchronized scrolling lyrics (coming soon).
- Search Functionality: Easily find tracks, artists, or albums within the local library.

## What's New

- **Full-Screen Detail View**: Upgraded Albums, Artists, and Playlists to use a dedicated, Spotify-style full-screen interface instead of inline lists.
- **Dynamic Adaptive Backgrounds**: Integrated `palette_generator` to dynamically extract the dominant color from album covers, seamlessly blending it into a smooth background gradient for the new detail views.
- **Fluid Gestures & Animations**: Added a smooth slide-up entry animation for the detail view and introduced an intuitive swipe-down gesture on the artwork to instantly close the screen.
- **Dedicated Shuffle Play**: Implemented a standalone "Shuffle Play" action button within the detail view that instantly randomizes the queue and starts playback without forcing the global music control's shuffle state on.
- **Seamless Navigation State**: Enhanced tab navigation to retain the `PageView` scroll state securely by dynamically locking horizontal swiping while inside a detail view, avoiding UI rebuilds.
- **Overlay Rendering Precision**: Detail views now render as standalone UI layers over the static main menu, preventing visual overlap. Added a 100% opaque solid backdrop layer underneath the dynamic gradient to completely mask the main UI during the slide animation.
- **Playlist Performance Optimization**: Drastically improved animation frame rates and eliminated load-lag when opening massive custom playlists by converting O(N²) array lookups into rapid O(N) Set lookups.
- **Refined Detail Aesthetics**: Replaced distorted stacked circular playlist artwork with standard 220x220 square covers perfectly centered with added top-clearance to beautifully accommodate mobile notches and timestamps.
- **Accurate Play Statistics**: Fixed an issue where the app's boot sequence would falsely inflate a track's total play count and manipulate the "Last Played" playlist simply by loading the previous session's track into memory.
- **Detail View 3-Dot Options**: Introduced a contextual top-right options menu inside the Detail View, empowering users to easily "Play Next" or "Add to Queue" the entire Album, Artist, or Playlist at once.
- **Advanced Multi-Select Playlist Management**: You can now tap "Add Songs" inside any custom playlist to bulk-add from a full library checklist, or tap "Add to Playlist" from any Album/Artist view to cherry-pick specific tracks to add to your custom mix.
- **Custom Playlist Management**: Directly from the new Detail View options menu, users can now gracefully Rename, Edit Covers, and Delete their custom-built playlists, seamlessly updating across the entire app state and shared preferences.
- **Dynamic Z-Index Layouts**: Restructured the root Stack hierarchy so the Mini Player always beautifully renders above the sliding Detail View overlay without obscuring the bottom of long song lists, solving overlap issues.
- **Detailed Play Statistics**: The "Most Played" playlist now renders the exact global play count next to each track's subtitle for deeper insight.
- **Extreme UI Performance Optimization**: Eliminated out-of-memory crashes and scrolling lag by universally limiting high-res image decoding to a 600px width buffer, sharing identical cache keys across the entire application interface.
- **System Back Button Interception**: Implemented a global `PopScope` that gracefully intercepts native Android back-button events, ensuring that open overlays (Lyrics, Full Screen Player, Detail Views) close sequentially instead of abruptly exiting the app.
- **Palette Generator Acceleration**: Supercharged the dominant color extraction algorithm by constraining its scanning region to a precise 100x100 pixel grid, eliminating UI freezing when sliding open playlists with heavy custom covers.
- **Instant Cache Invalidation**: Overhauled the detail view rendering pipeline so modifying a track's metadata instantly clears the cache and rebuilds standard playlists (like "Recently Added") with their newly assigned cover art.
- **Glassmorphism Mini Player Scrolling**: Re-architected the main menu layout to remove rigid bounding boxes, allowing track lists and playlists to flow dynamically underneath the semi-transparent mini player.

## Previous Updates

- **Track Options Menu**: Replaced the quick-favorite icon with a modern 3-dot "More Options" menu. It features a sleek modal bottom sheet with quick actions (Play Next, Add to Queue, Go to Album/Artist, etc.).
- **Smooth Audio Transitions**: Implemented a 150ms fade-in and fade-out audio transition when toggling play and pause to eliminate abrupt audio clipping or popping sounds.
- **Refined Player UI**: The duration control slider now elegantly spans the full horizontal width, aligning perfectly with the track duration timestamps.
- **UI Layout Enhancements**: The navigation filter pills (Songs, Playlists, Artists, Albums) have been upgraded to evenly fill the horizontal space, perfectly matching the search bar width.
- **Mini Player Upgrade**: Added a "Skip Previous" button to the persistent mini-player for easier navigation.
- **Default Playback State**: "Repeat All" is now seamlessly enabled by default when the application starts.
- **User Custom Playlists**: Added the ability to create new custom playlists directly from the Playlists tab or the track options menu. Tracks can now be seamlessly added to these user-defined playlists.
- **Virtual Metadata Editing**: Users can now edit a track's Title, Artist, and Album metadata safely from the track options menu. Changes are applied virtually within the app without altering the original audio files.
- **Image Picker Integration**: Users can now set custom cover images from the device gallery for both their created playlists and as virtual overrides for track album art.
- **Track Deletion**: A new "Delete from device" option was added to the track options menu, allowing users to physically remove unwanted audio files from their local storage.
- **Audio Transition Fixes**: Completely revamped track transition logic with smooth crossfading, preventing audio crackling/buzzing when rapidly switching tracks. Also implemented a robust fallback synchronization system to guarantee the Now Playing UI and the core audio engine always stay in perfect sync, even when track loading is abruptly aborted during spam taps.
- **Enhanced Navigation UX**: Switched tab interactions to utilize smooth sliding animations instead of abrupt page jumps, and streamlined the Full-Screen Player interface by removing redundant option buttons.
- **High-Resolution Artwork**: The Now Playing screen now dynamically fetches high-resolution album artwork, eliminating blurry or pixelated cover images.
- **Spotify-like Dynamic Backgrounds**: Both the Mini Player and the Full-Screen Now Playing UI now adapt their background colors and gradients based on the dominant color extracted from the currently playing track's artwork.
- **Interactive Drag Gestures**: Replaced static tap-to-open mechanics with smooth, physics-based vertical drag gestures. Users can now seamlessly drag the Mini Player up to reveal the Now Playing screen, and drag down to dismiss it.
- **Polished UI Details**: Upgraded global touch feedback (splash/ripple effects) across all list items to feature rounded corners, matching the app's modern aesthetic.

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

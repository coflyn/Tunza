# Tunza Audio Player

![License](https://img.shields.io/badge/license-GPLv3-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)

Tunza is a modern, feature-rich local audio player built with Flutter. It focuses on providing a premium listening experience with a clean user interface, seamless background playback, and smart track management.

## Features

- **Local Audio Scanning**: Automatically queries and fetches audio files from scoped device storage with reactive permission controls.
- **Smart Playlists Engine**: Dynamically aggregates tracks into _Favourites_, _Recently Added_, _Last Played_, and _Most Played_ lists based on secure play statistics.
- **Background Playback**: OS-level backgrounding service with system notifications, lock screen media controls, and native audio sessions.
- **Adaptive Aesthetics**: Spotify-like dynamic background color extraction from album art using `palette_generator`, painting beautiful rich linear gradients.
- **Premium Flat UI/UX**: Solid dark material components, smooth vertical swipe-down physics to close players/views, and premium custom `24` rounded corners matching modern OS styling.
- **Dynamic Sleep Timer**: Automatically stop audio playback with built-in presets (15m, 30m, 60m) or custom inputs, complete with a live counting indicator on the player header.
- **Precision Audio Transitions**: Custom Crossfade adjustments (0ms to 3000ms) with a 150ms fade-in/fade-out playing transition to avoid pops/crackles.
- **Auto Regex Cleaner**: An aggressive, native RegExp title cleaner that removes underscores, empty brackets, and cluttered suffixes (like `4K Remastered`, `Official Video`, `Remastered`).
- **Dynamic Artist Extraction**: Automatically parses song titles to extract and populate missing artist fields when the local file's metadata tags are empty or unrecognized.
- **Virtual Metadata Editor**: Edit song Titles, Artists, and Albums virtually inside the app interface without touching the physical source files.
- **Custom Covers & Art**: Select custom images from your device gallery to personalize custom playlists or override standard album covers.
- **Dynamic Durations & Equalizers**: Formatted track durations are beautifully shown next to song lists, which seamlessly transform into live-animated `MiniMusicVisualizer` equalizers when tracks are actively playing.
- **Pixel-Perfect Margin Alignment**: Custom spatial translations (`Transform.translate`) align song controls and durations at a precise `24px` horizontal screen margin, perfectly lining up with page pills, search headers, and playlist card boundaries.
- **Search & Navigation**: Easily query tracks, artists, or albums and navigate through horizontal swipable tabs.

## What's New

- **Android 14+ Background Audio & Notification System Restored**:
  - **R8 ProGuard Rules for Reflection Protection**: Added target native `proguard-rules.pro` to prevent the R8 optimizer from mangling and stripping the background `audio_service` classes (specifically `com.ryanheise.audioservice` and `com.ryanheise.just_audio_background`), resolving a silent native reflection crash when initiating background playback.
  - **Interactive Notification Permission Router**: Implemented a modern startup permission scanner that detects blocked notification channels (especially on aggressive OEM skins like Transsion HiOS/XOS) and presents a premium modal offering to launch directly into the phone's OS Settings app info page via `openAppSettings()`.
  - **Compliant Mipmap PNG Notification Icon**: Configured the background service to explicitly use a compliant `.png` formatted asset (`mipmap/ic_launcher`) as the small notification icon, avoiding vector XML `Resources.NotFoundException` crashes on older/custom OEM devices.
  - **Strict Android 14 Compliance**: Registered `FOREGROUND_SERVICE` and `FOREGROUND_SERVICE_MEDIA_PLAYBACK` permissions natively, and mapped `AudioService` with `foregroundServiceType="mediaPlayback"` in the Android Manifest.
  - **Ultra-High-Performance 3-Track Sliding Window Queue**: Replaced single-source loading with a dynamic 3-track `ConcatenatingAudioSource` sliding window (`[Previous Track, Current Track, Next Track]`) to natively enable Previous/Next media control buttons in the lock screen and notification drawer without memory overload or image loading UI lag.
  - **Programmatic Loading Guard**: Implemented a robust `try-finally` execution guard around track initialization to filter out transient player index state transitions, preventing concurrent source loads and eliminating `'loading interrupted'` errors entirely.
- **Duration UI & Live Equalizer Toggle**:
  - Integrated track duration fields in the underlying `Track` model mapping.
  - Implemented dynamic trailing row logic: tracks display their beautifully formatted duration (`MM:SS`) when idle, which seamlessly crossfades into an active, green 3-bar `MiniMusicVisualizer` reacting to the playback engine when playing.
- **Precision Grid Alignment (Strict 24px Margin)**:
  - Addressed native Flutter `ListTile` layout constraints where the trailing slot was forced away from the screen edge.
  - Custom-translated the trailing control row `8px` to the right (`Transform.translate(offset: Offset(8, 0))`), pulling the 3-dots option buttons and duration values into perfect mathematical alignment at a strict `24px` margin, consistent with the top search bar and filter pills.
- **Static Artwork Aesthetic**:
  - Stabilized the Fullscreen Now Playing cover art by stripping the `AnimatedScale` shrink animation. The album art now remains flat, static, and centered in gorgeous full scale when paused.
- **Header Border Cleansing**:
  - Removed black container outlines and border borders from the Detail View cover headers, letting high-resolution images merge seamlessly with the adaptive palette-based dynamic gradients.
- **Massive Architectural Refactoring**: Successfully decoupled the bloated 3,600+ line `main.dart` into specialized UI modules (`player_ui`, `detail_views_ui`, `tabs_ui`, `modals_ui`) using Dart's `part` and `extension` system. This reduced the main application file down to 1,200 lines while maintaining flawless local state synchronization without requiring external state management dependencies.
- **Settings Dashboard (Premium Flat UI)**: Completely redesigned the settings screen to follow the clean, flat design language of the Songs and Playlists tabs. Swapped bloated glassmorphic cards and glowing background ornaments for standard deep dark `0xFF0A0A0A` backgrounds and flat, solid `0xFF161616` cards with `borderRadius: BorderRadius.circular(12)`.
  - **M3 Scrolled-Under Control**: Prevented native Material 3 AppBar green-tint behavior by disabling `scrolledUnderElevation` and zeroing `surfaceTintColor`, maintaining a flat solid black header during scrolling.
  - **Dynamic Sleep Timer**: Stop playback automatically after a set duration. The Full-Screen Player's header text dynamically transforms into a live countdown when active. Accessible from both the Settings screen and the **3-dots Track Options Menu** for any song, including custom minute inputs.
  - **Audio Crossfade**: A customizable slider (0 - 3000ms) to seamlessly fade between tracks without gaps.
  - **Auto Regex Cleaner**: Automatically clean messy song titles by stripping redundant artist names (e.g., "Tom Odell - Hello" becomes "Hello") and removing cluttering tags like "(Official Video)", "[Lyric Video]", or "(Audio)". Powered by a custom Dart RegExp parser to avoid native platform parsing exceptions.
  - **Short Audio Filter**: A smart toggle to bypass scanning short audio files (<30s) like voice notes and ringtones, actively filtering the MediaStore results on library rescan.
  - **Specific Folder Scan**: A fully implemented premium folder manager! It scans all audio files on the device, groups them by their parent directory path, and presents a beautiful interactive switch list showing each folder's simple name, full system path, and active song counts. Users can toggle folders on/off to instantly sculpt and customize their music library.
  - **Premium Song Hiding & Scoped Storage Fallbacks**:
    - **Explicit "Hide from Library"**: Placed directly above "Delete from device" in the 3-dots Track Options Menu. Users can cleanly hide any song from Tunza (soft delete) without touching physical device storage, providing a safe alternative for Android 10+ devices bound by Android Scoped Storage restrictions.
    - **Smart Deletion Fallback**: If physical file deletion fails due to Scoped Storage permission denials, Tunza intelligently catches the error and offers a premium dialog to seamlessly hide the track from the active library instead.
    - **Unified "Hidden Tracks" Manager**: Added a brand new "Hidden Tracks" management dashboard in Settings. It uses a high-performance, cached bottom sheet to inspect all hidden audio. Tracks are beautifully categorized with distinct visual badges: orange `HIDDEN` badges for manually hidden tracks and cyan `SHORT AUDIO` badges for tracks filtered by the short duration scanner. Users can restore manually hidden songs back to their library with a single tap.
    - **Zero-Flicker Directory & Filter Refresh**: Overhauled the state synchronization flow. Caching the MediaStore query Future prevents FutureBuilder re-query flicker during toggles, and silencing the global fullscreen loading overlay during background rescans ensures a completely fluid, instant 0ms interface transition.
  - **App Data Reset**: A secure "danger zone" to wipe play histories, custom playlists, and favorites without deleting local files.
  - **Support Developer Integration**: Added a high-visibility support tile using a warm pink-red heart icon linking directly to the creator's Sociabuzz page (`https://sociabuzz.com/coflyn`) for secure community donations.
  - **Hardware Integrations**: Added "Pause on Disconnect" to halt playback when headphones are unplugged.
  - **Developer Tools**: Native GitHub repository integration via `url_launcher` and Update check placeholders.
- **Premium Cover Art Rounding**: Upgraded the border radius of the fullscreen music player artwork and album/playlist detail covers to a high-end `24` radius. Patched the core `QueryArtworkWidget`'s native borders to seamlessly match this radius, eliminating any platform-level sharp corners and matching the design aesthetics of industry giants like Apple Music.
- **State-Driven Micro-Feedback**: The fullscreen player header title now dynamically switches between "Now Playing" and "Paused" in real-time depending on the underlying playback status, delivering immediate visual confirmation of the audio engine state.
- **Git Tracking & Linter Eradication**: Patched Git rules to secure 100% Dart classification on GitHub by vendoring platform folders, and cleared out all linter warnings across the entire codebase.

## Previous Updates

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

The project has been refactored into a highly modular, decoupled architecture using Dart's `part` and `part of` directives, keeping local state synchronization lightweight and seamless:

- **`lib/main.dart`**: Root application entry, boot sequence initialization, local state controller, persistent preferences loading, and storage media query scans.
- **`lib/ui/player_ui.dart`**: Fullscreen adaptive music player UI. Houses physics-based swipe-down gestures, sliding mini players, and dynamic palette-based gradients.
- **`lib/ui/detail_views_ui.dart`**: Dynamic detail overlays for Artists, Albums, and custom/default Playlists.
- **`lib/ui/tabs_ui.dart`**: Viewport page layouts hosting horizontal swipable tabs (Songs list, Playlist cards, Artist list, Album cards) and the standard search system.
- **`lib/ui/modals_ui.dart`**: Interactive overlays including track settings bottom sheets, dynamic Sleep Timer lists, cover selection tools, and virtual metadata editing.
- **`lib/screens/settings_screen.dart`**: A standalone, polished Material 3 settings menu with group card components, sliders, and toggle switches.

## Dependencies

- **`just_audio`**: High-performance local and streaming audio playback engine.
- **`just_audio_background`**: OS-level audio session backgrounding and locking controls.
- **`on_audio_query`**: Scoped querying of local media storage structures.
- **`permission_handler`**: Runtime operating system authorization checks (Storage/Notification).
- **`shared_preferences`**: Local key-value state persistence (play count, custom playlists, settings).
- **`google_fonts`**: Premium text styles and typography integration.
- **`mini_music_visualizer`**: Real-time visual music playing equalizer bars.
- **`fluttertoast`**: Non-blocking platform native alert toasts.
- **`palette_generator`**: Extraction of dynamic dominant palette colors from album art.
- **`image_picker`**: Device photo gallery selection utilities.
- **`audio_session`**: Native platform hardware-level audio session interrupt binds.
- **`url_launcher`**: Intent dispatching to external links (GitHub / Sociabuzz).

## Build Requirements

- Android: Requires minSdk 21 and targetSdk 33 or higher.
- iOS: Requires iOS 11.0 or higher. Note that Swift Package Manager adoption may be required for certain plugins in future updates.

## Development Notes

When running on Android 13 or higher, ensure that the application is granted the `READ_MEDIA_AUDIO` permission for proper library scanning. The application uses `content://` URIs to support scoped storage natively.

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0). See the [LICENSE](LICENSE) file for more details.

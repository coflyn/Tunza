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

- **Seamless Notification Audio Transitions**:
  - **Eliminated Track Switching Crackles ("bzzt" sound)**: Overrode the OS-level background `skipToNext()` and `skipToPrevious()` event listeners in `MyAudioHandler` to programmatically trigger the app's advanced `_playNext()` and `_playPrevious()` engines. This swaps sudden native jumping with a premium crossfade transition (a graceful 150ms fade-out of the active song, followed by a clean source load, and a smooth fade-in).
  - **Premium Notification Play/Pause Fading**: Replaced direct instant playback switches (`player.play()` / `player.pause()`) inside `MyAudioHandler` with the app's custom `_playWithFade()` and `_pauseWithFade()` routines. Toggling play or pause from the lock screen or notification drawer now executes a beautiful, smooth volume fade, completely eliminating abrupt waveform-cut crackles and pop sounds.
  - **Robust Fallback Protection**: Added static instance checking on the main screen controller (`_MainScreenState.mainScreenState`). If the background service is triggered while the main app UI is fully closed/terminated by the system, it automatically falls back to raw native playback controls without crashing.
- **Sleek Minimal Notification Drawer & Status Bar Compliance**:
  - **Clean Notification Layout**: Removed cluttered and redundant custom actions (such as the Close "x" button and the secondary Favorite button) from the persistent notification view. The drawer now presents a beautifully clean, simplified 3-button standard layout (**Previous**, **Play/Pause**, **Next**).
  - **Optimized Android Compact View**: Adjusted compact indices mapping to `[0, 1, 2]`, ensuring all three essential controls are perfectly proportioned and displayed in both compact and expanded system notification states.
  - **Compliant Monochromatic Notification Icon**: Changed `androidNotificationIcon` in `AudioServiceConfig` to target `'drawable/ic_notification'`. This replaces the colorful launcher icon with a beautifully designed, transparent vector music note icon, complying with modern Android design rules and preventing solid white squares in the system status bar.
  - **ProGuard Shrinking Protection**: Updated `android/app/src/main/res/raw/keep.xml` to lock and retain `@drawable/ic_notification` in the final release binary, avoiding aggressive ProGuard asset stripping during compilation.
- **Now Playing Favorite Integration**:
  - **Interactive Now Playing Favorite Button**: Added a dedicated, reactive Favorite toggle button right next to the song Title and Artist inside the full-screen player view.
  - **Responsive Ellipsis Constraints**: Wrapped the Title and Artist column in an `Expanded` parent to dynamically calculate layout boundaries. Long titles automatically truncate with a sleek ellipsis (`...`) instead of overflowing, pushing the favorite button, or clipping off-screen.
- **Android 11+ Package Visibility & External Link Repairs**:
  - **Solved Link Launch Exceptions**: Resolved a package visibility blocker where modern Android OS versions (Android 11+) prevented external browser dispatching, throwing a "Could not open link" error. Added a proper HTTP/HTTPS `<queries>` package intent structure directly inside `AndroidManifest.xml` to allow system browser detection.
  - **Modernized url_launcher Direct Invocation**: Bypassed strict dependency on the flaky `canLaunchUrl` checker by modernizing the settings screen launcher code to call `launchUrl(..., mode: LaunchMode.externalApplication)` directly inside a try-catch safety net, guaranteeing 100% link opening reliability.
- **Zero-Flicker Hidden Tracks Management**:
  - **Static Future Caching**: Fixed a significant UI flickering bug where dragging or scrolling the bottom sheet triggered instant library rebuilds and initiated concurrent local storage queries. Implemented a cached `_songsFuture` variable in the settings state, initialized exactly once on button tap and cleared only when dismissed.
  - **Instant 0ms Layout Transitions**: Users can now smoothly drag, swipe down, and restore hidden or short tracks with instant, fluid 0ms rendering feedback and zero future rebuilding lag.
- **Instant Offline Library Caching (0ms Cold Start)**:
  - **Fail-Safe Startup Cache**: Resolved a critical Android system bug where the OS MediaStore indexing or permission-bridge latency during a cold-start occasionally returned empty tracks, wiping out the user's scan library.
  - **Persistent Local Serialization**: Created automatic JSON serialization for the mapped `_allTracks` list directly inside `SharedPreferences` upon every successful scan.
  - **0ms Immediate Startup Rendering**: When the app opens, it instantly reads and displays the cached songs list without waiting for the slow native permission bridge checks, providing a spectacular, lag-free 0ms startup time.
  - **Non-Destructive Background Sync**: Background library rescans now execute silently and securely. If a rescan fails or is temporarily blocked, the app securely retains the existing cached library, preventing "empty library" screens.
- **Context-Aware Premium Now Playing Header**:
  - **Dynamic Source Recognition**: Refactored the full-screen player top subtitle. Tapping a track or playing a group now dynamically reads and evaluates the exact source context—whether played from an Album, Artist, Playlist (including Favourites, Most Played, Recently Added, Last Played, and custom user playlists), or main Library.
  - **Curated Visual Layout**: Renders a gorgeous centered two-line header containing the small, uppercase letter-spaced source type (e.g. `PLAYING FROM PLAYLIST`) and the bold name of the source (e.g. `Most Played`), matching premium standards perfectly and avoiding redundant classifications.
- **Scrollable Detail View Buttons & Downward Back Chevron**:
  - **Scrollable Cover Album & Gesture Forwarding**: Resolved a gesture conflict where the cover image's custom `GestureDetector` blocked the list's scrolling when users dragged upwards on it. Implemented an intelligent gesture-direction evaluator: dragging down smoothly slide-dismisses the page, while dragging up programmatically forwards the scroll delta directly to a dedicated `_detailScrollController`, enabling perfect, fluid, and uninterrupted scrolling across the entire screen.
  - **Centralized Scroll Reset**: Integrated an automatic reset hook. Switching to or opening a new detail page instantly jumps the `_detailScrollController` back to `0.0`, ensuring every library view starts perfectly from the top track.
  - **Premium Aligned Drag Handle**: Integrated a sleek, centered horizontal grabber pill (width: 40, height: 5, with rounded corners and a premium `white.withOpacity(0.15)` finish) directly inside the top Row, perfectly aligned on the same horizontal axis as the Back Chevron and the 3-Dots actions.
  - **Non-Sticky Natural Scrolling**: Moved the detail view top bar buttons (Back, Drag Handle, and 3-dots actions) out of the overlay `Stack` layer and integrated them directly at the top of the header Column. The entire row now scrolls up naturally alongside the header cover image, resolving the annoying "sticky buttons" overlay bug.
  - **Intelligent Downward Back Chevron**: Replaced the sideways back chevron (`Icons.arrow_back_ios_new`) with a sleek downward-pointing chevron (`Icons.keyboard_arrow_down`), perfectly matching modern premium sliding-panel UI paradigms and returning cleanly to the bottom.
- **Repeat-Aware Queue & Smart Play Next Reordering**:
  - **Dynamic Repeat-Aware 'Up Next' list**: Replaced the static queue list with a custom-engineered repeat-aware calculator. Setting Repeat One displays only the currently playing track and leverages `just_audio`'s native `LoopMode.one` to repeat the current song seamlessly without advancing to next items; Repeat All calculates remaining tracks and dynamically wraps around to the beginning, showing the infinite loop; Repeat Off lists tracks to the end without wrapping.
  - **Zero-Duplicate 'Play Next' & 'Add to Queue'**: Implemented a mathematically rigorous queue reordering routine. Tapping 'Play Next' or 'Add to Queue' checks for pre-existing copies of the track in the active queue. If present, it safely removes the track from its old position, cleanly shifts both normal and shuffled indices to maintain absolute queue alignment, and inserts it at the target position, guaranteeing a duplication-free queue.
  - **10-Second Play Count Threshold**: Designed an intelligent listener within the `positionStream` that only increments a track's play count (qualifying it for "Most Played") if it has been played continuously for at least 10 seconds. For short files (e.g. under 10 seconds), the system counts the play if it reaches within 500ms of completion. The counter increments exactly once per song load, avoiding duplicate triggers during pauses or seeks.
  - **Real-Time Silent Player Sync**: Integrated dynamic active source updates. Adding or reordering tracks instantly mutates the active concatenating audio source in the background without causing any volume drops or playback interruptions.
- **Smart Playlist Management & Duplication Shield**:
  - **Intelligent Song Duplication Prevention**: Added check loops within the Playlist modal. When a user tries to add a track already inside the selected playlist, it skips it and presents a tailored Toast message ("'Track Title' is already in Playlist Name").
  - **Comprehensive Multi-Track Status Toasts**: Enhanced the multi-select playlist interface to intelligently calculate skipped items and report descriptive status results (e.g., "Added 5 songs to Chill (2 skipped)").
- **Seamless Fade-Out Sleep Timer & Premium Sliding Sheet**:
  - **Premium Drag-to-Dismiss Sleep Sheet**: Replaced the standard, boring `AlertDialog` with a gorgeous, custom-styled, rounded `showModalBottomSheet` matching the user's sleek screenshot. Includes a central bold title, custom padding, and a neat drag-handle at the top for intuitive swipe-to-dismiss closing.
  - **Precise 'End of track' Support**: Added native position tracking logic. When 'End of track' is selected, a listener monitors song progress and smoothly fades out playback exactly 350ms before the current track terminates naturally, regardless of active repeat modes.
  - **Eliminated Sleep Crackles**: Replaced the harsh and abrupt direct pause method inside the periodic Sleep Timer callback with our high-fidelity `_pauseWithFade()` routine. When the sleep timer runs out, the music now gracefully fades out to 0% volume over 150ms instead of stopping instantly and producing a "bzzt" pop sound.
- **Reactive Cache-Invalidated Hidden/Deleted Tracks**:
  - **Zero-Lag State Synchronization**: Added automated `_cachedDetailKey = null` clearing hooks directly into song hide actions, device delete protocols, and general library rescans. Hiding or deleting a track now instantly synchronizes all active grid lists, Album detail, and Artist detail views in real-time, eliminating any visual discrepancies.

## Previous Updates

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
- **Premium Cover Art Rounding**: Upgraded the border radius of the fullscreen music player artwork and album/playlist detail covers to a high-end `24` radius. Patched the core `QueryArtworkWidget`s native borders to seamlessly match this radius, eliminating any platform-level sharp corners and matching the design aesthetics of industry giants like Apple Music.
- **State-Driven Micro-Feedback**: The fullscreen player header title now dynamically switches between "Now Playing" and "Paused" in real-time depending on the underlying playback status, delivering immediate visual confirmation of the audio engine state.
- **Git Tracking & Linter Eradication**: Patched Git rules to secure 100% Dart classification on GitHub by vendoring platform folders, and cleared out all linter warnings across the entire codebase.

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

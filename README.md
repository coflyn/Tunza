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
- **Custom Player Background Styles & Real-Time Wallpaper Editor**: Support for four breathtaking Now Playing rendering modes: **Dynamic Gradient** (color extracted linear blend), **Apple Blurred Cover** (clean, high-fidelity glassmorphic overlay powered by an optimized hardware-accelerated `ImageFiltered` widget wrapped inside a precise `ClipRect` to prevent bleeding), **AMOLED Deep Black** (pure solid black for visual minimalism and battery saving), and **Custom Gallery Image** (pick any custom photo from your device gallery). Features a **real-time wallpaper editor** under Settings to adjust **Blur Level (0-60)**, **Dim Level (0-90%)**, and **Zoom Scale (1.0x-3.0x)** with an interactive miniature live mockup preview!
- **Global 3-Choice Theme Modes**: Rich selection between:
  - **Dark Mode**: Sleek, battery-saving dark theme (`#0A0A0A` scaffold, `#161616` cards).
  - **Light Mode**: Gorgeous, clean light theme (`#F6F8FA` scaffold, `#FFFFFF` cards).
  - **Custom Theme Mode**: High-fidelity theme customizer supporting a glowing **Dynamic (Artwork)** background (which automatically extracts and tints the entire app backdrop using an HSL mathematical safety algorithm), **5 Luxury Solid Color Backdrops** (Deep Navy, Forest Green, Midnight Wine, Sunset Terracotta, Slate Gray-Blue), or **Custom Gallery Image Wallpaper** (pick any custom photo from your device gallery). The entire application UI—including scaffold backdrops, list cards, settings cards, typography colors, action icons, chevrons, and submenus—instantly adapts with premium responsiveness. Features a **real-time theme wallpaper editor** inside the Settings panel to customize **Blur Level (0-60)**, **Dim Level (0-90%)**, and **Zoom Scale (1.0x-2.0x)** with an interactive live miniature replica mockup card of the Library Home Screen!
- **Dynamic Theme Accent Customization**: High-fidelity custom accent preset selector with 9 premium solid presets (Spotify Green, Apple Red, Deep Purple, Tidal Cyan, Sunset Orange, Sakura Pink, Luxury Gold, Sapphire Blue, Electric Lime) or **Dynamic (Artwork)** color matching.
- **HSL Contrast Safety (Auto-Brightener)**: Real-time mathematical luminance safety interceptor that automatically boosts dark extracted cover art colors into readable pastels/neons, mapping pure black/desaturated covers to a sleek, premium Silver-Grey.
- **ValueNotifier Real-Time State Sync**: Continuous visual color stream coupling that propagates theme modifications and cover artwork changes instantly across all pushed settings panels, switches, and sliders in real-time.
- **Interactive Lyrics Engine**: Synced LRC & plain text support with zero truncation. Renders dynamic word-wrapping karaoke streams styled perfectly to Tunza's custom fonts without cutting off text.
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

- **Spotify-Style Detail Views**: Re-engineered the Album, Artist, and Playlist Detail Views to match modern Spotify aesthetics. Features include a left-aligned typography layout, a prominent 260x260 main cover art (up from 220px), and a streamlined action row integrating shuffle and a circular play button without cluttered avatars.
- **Dynamic 4-Grid Playlist Covers**: Custom and smart playlists now automatically generate a stunning 4-grid cover art collage if the playlist contains tracks from 4 or more distinct albums, mimicking premium music streaming platforms.
- **Zero-Jank Deferred Grid Loading**: Specifically engineered a `_DeferredGridCover` stateful widget for the 4-grid playlist art. This intercepts and defers the heavy concurrent native image decoding requests until *after* the UI slide animation completes (400ms delay), completely eliminating frame drops and visual flickering when opening large playlists.
- **RepaintBoundary Animation Optimization**: Completely eliminated UI lag and dropped frames when opening Detail Views. By wrapping the heavy `ImageFilter.blur` background gradients in a `RepaintBoundary`, the complex blur effects are now cached as hardware textures and seamlessly translated during the 60fps `AnimatedSlide` sequence.
- **Uninterrupted Fade-in Animations**: Solidified the `_FadeInSlideUp` animation engine with robust internal state caching. The list items now guarantee a smooth, complete fade-in cascade upon app load, regardless of how many asynchronous background processes or `setState` rebuilds are triggered concurrently.
- **Stable & Centered Lyrics Layout**: Refined the synced lyrics interface to maintain a strict geometric baseline height for all text lines. By locking the item height and unifying the `fontSize` (leveraging `fontWeight` and opacity to convey the active line), the lyrics list is now mathematically guaranteed to keep the active line perfectly centered on the screen without drifting downwards. Additionally, navigating to a new track now instantly resets the scroll position to the top, delivering a seamless Apple Music-style karaoke experience.
- **Unified Now Playing & Lyrics Experience**: Seamlessly merged the album artwork and full-screen lyrics views into a single, cohesive interface. Users can now instantly toggle between the cover art and lyrics via a smooth, zero-latency crossfade (`AnimatedOpacity`) simply by tapping the artwork or using the dedicated lyrics button. The UI features a single, unified persistent header that elegantly animates its text context while retaining persistent navigation controls.
- **Zero-Lag Swipe Gestures & Flicker-Free Closure**: Completely re-engineered the swipe-to-close physics engine for both the Now Playing Player and all dynamic Detail Views (Albums, Artists, Playlists). By fully replacing expensive `setState` calls with high-performance `ValueNotifier` and `ListenableBuilder` architecture, the layout tree no longer rebuilds during drags. Additionally, `AnimatedSlide` components are now kept permanently mounted in the tree, resolving all visual flickering and frame drops when swiping down.
- **Immediate Global Back Navigation**: Hardened the system back-button behavior via a robust `PopScope`. Triggering a back navigation now instantly closes the Now Playing player regardless of whether lyrics are active, completely eliminating confusing multi-step exit behaviors.
- **Advanced Playback Settings**: Added two highly requested user controls in the Settings menu: **"Resume after Call"** (which automatically resumes music after a phone call ends) and **"Play Together with other Apps"** (which dynamically reconfigures the native `AudioSession` to mix audio without pausing when other apps play sound).
- **Native Audio Interruption Override**: Bypassed the default native ExoPlayer focus-loss behavior within `just_audio`. Tunza now fully controls audio interruptions on the Dart side, ensuring the "Play Together" feature flawlessly mixes audio without being unexpectedly paused by Android's native audio focus manager when other apps play sound.
- **Synchronized Hidden Tracks Cache**: Resolved a persistent state desynchronization issue where tracks manually hidden or deleted by the user would temporarily reappear in the 'Recently Added' and 'All Songs' lists upon app restart. The JSON caching mechanism (`cached_tracks_list`) is now instantly re-serialized and persisted to `SharedPreferences` the moment a track is hidden, ensuring a mathematically accurate track count at all times.
- **Real-Time Dynamic Playlist Caching**: Upgraded the caching engine for smart playlists (Most Played, Last Played, Favourites). The detail views now utilize a dynamic cache key payload that tracks list sizes and play-count sums, guaranteeing that the Most Played tracks instantly update and re-render in real-time the moment a song finishes playing.
- **Animated Instrumental Wave**: Implemented a dynamic `_WaveDots` custom widget inside the synced lyrics engine. When the engine encounters an empty lyrics line or an instrumental break (e.g., `♪`, `[music]`, `instrumental`), it organically replaces the blank text with a beautiful, 3-dot sine-wave ocean animation. The wave naturally scales down and stops moving when the instrumental segment loses focus.
- **Buttery Smooth Detail View Layouts**: Radically optimized the layout rendering logic for Album, Artist, and Playlist Detail Views. Moved the heavy, dynamic list-building logic into the persistent `child` parameter of the `ListenableBuilder`. This completely decouples the expensive view generation from the 60fps drag-to-close swipe updates, guaranteeing flawless, frame-perfect animation transitions when opening or closing large albums.
- **Persistent Drag Offset Resolution**: Repaired a visual bug where Detail Views (Albums, Artists) would get stuck and open halfway down the screen. The issue was caused by residual vertical swipe-down values persisting in memory. Built a precise post-frame hook into the `ListenableBuilder` to seamlessly wipe the drag tracking metrics back to `0.0` automatically upon closing, without interrupting the close-out animation frame sequence.
- **Orphaned Notification Cleanup**: Integrated native `WidgetsBindingObserver` to rigorously track the application's lifecycle state. If the app is killed from recent tasks (`AppLifecycleState.detached`) while playback is paused, the background audio session is immediately destroyed. This prevents the Android OS from abandoning a dead, unresponsive media player notification in the system tray.
- **Premium Lyrics Interface**: Completely overhauled the full-screen lyrics view to match the gorgeous, high-fidelity aesthetics of Apple Music and Spotify. Active lyrics are now emphasized with larger, bolder typography and bright white coloring, while inactive lyrics gracefully fade into a semi-transparent white. The layout logic was also restructured to dynamically push playback controls (Timeline, Play/Pause, Skip, and Navigation actions) to the very bottom edge of the screen, creating massive negative space that lets the karaoke-style lyrics breathe beautifully.
- **UI Flickering Resolution**: Stabilized the `_FadeInSlideUp` animation structure and secured `QueryArtworkWidget` state retention using value keys. This completely eliminates UI screen flickering and image reloading when switching tabs or selecting new tracks.
- **Background Shuffle Logic Fix**: Repaired a core native playback bug where the `ConcatenatingAudioSource` ignored the shuffled playback order, reverting to a sequential list. The audio session now rigorously enforces `_shuffledIndices` and `_repeatMode` rules for accurate cross-track transitions.
- **Search Keyboard Stabilizer**: Hardened the search `TextField` by assigning a persistent, managed `FocusNode`. This stops the software keyboard from glitching and erroneously re-appearing during widget `setState` re-renders. The keyboard now politely dismisses immediately upon selecting a track.
- **Smart Search Queue Integration**: Adjusted how search queries behave dynamically. Selecting a song from a filtered list now starts playback immediately but safely restores the remainder of your sorted library into the play queue, ensuring playback doesn't stop after a single track.
- **Instant Metadata Restoration**: Added a dynamic "Reset" button inside the Edit Metadata modal to safely clear custom memory overrides and automatically re-scan the native device library, instantly restoring the song's original embedded audio tags and cover art.
- **Minimalist Now Playing UI**: Removed the redundant volume slider from the Now Playing viewport to expand negative space, delivering a much cleaner, premium aesthetic that relies organically on native device hardware volume keys.
- **Mobile-First Project Optimization**: Purged unused platform compilation directories (`linux`, `macos`, `windows`, `web`) to aggressively clean the repository structure, reduce disk usage, and accelerate IDE indexing, formally cementing the project's laser focus on Android and iOS.
- **Instant Shuffle Activation**: Engineered a `_refreshAudioSourceWindow` method that hot-swaps the native `ConcatenatingAudioSource`'s prev/next tracks in real-time when the shuffle toggle is pressed. Shuffle now takes effect immediately on the current song instead of waiting until the next track transition.
- **Search Engine Optimization**: Upgraded the local search functionality by implementing a 300ms debounce timer to prevent UI jank during rapid typing, integrated `.trim()` to safely ignore accidental leading/trailing spaces, and mapped the keyboard to native search actions (`TextInputAction.search`) for an intuitive dismissal experience.
- **Custom APK Output Naming**: Configured `applicationVariants` in `build.gradle.kts` to rename build outputs to `tunza.apk` (or `tunza-<abi>.apk` for split builds), replacing the default `app-release.apk` naming convention.
- **Custom Background Pan Controls**: Upgraded the wallpaper customization engine to support fine-grained XY offset alignments (Horizontal and Vertical Pan) via native `Alignment` properties alongside the existing zoom scaling. Users can now pinpoint exact visual focal points for their custom theme and player backgrounds, completely eliminating rigid center-crop limitations.

## Previous Updates

- **Full custom Theme Modes & Wallpaper Engine Integration**:
  - **Dark, Light & Dynamic custom Overlay**: Fully supports "Dark", "Light", and "Dynamic" background overlay choices for custom wallpapers, making the global background aesthetics fully cohesive.
  - **Dynamic Theme Overlay Luminance Resolution**: Employs mathematical HSL luminance analysis (`Color.computeLuminance()`) to automatically resolve contrasting text styles, settings cards, action buttons, and icons depending on whether the dynamic artwork is light or dark.
  - **Isolated Live Mockup Preview Customizer**: Uses a localized `Builder` and private `isMockLight` state to decouple the miniature live mockup card from the parent Settings screen, eliminating visual bleeding and permitting absolute styling isolation during real-time layout testing.
- **Normalized Library & List Layout & Typography**:
  - **Font Size Harmonization**: Standardized title typography across core viewports by scaling and unifying the primary Library (Songs) list item titles to **`15`** to perfectly match the elegant design scale of the Artists and Albums views.
  - **Vertical Spacing Alignment**: Harmonized vertical spacing of Library songs list items by setting `contentPadding` top/bottom to **`4`**, keeping the Songs list first item exactly aligned with Artists and Albums view heights.
  - **Pixel-Perfect Trailing Alignment**: Removed right padding on both Songs and Playlists tiles and translated trailing widgets by `12` pixels to the right, aligning three-dots visual centers perfectly with Artists/Albums chevrons.
- **High-Fidelity Detail View Top Bars**:
  - Redesigned the top header bars inside the Album, Artist, and Playlist Detail Views to 100% align with the beautiful Now Playing header layout. Integrates dynamic `SafeArea` placement, a centered top-level drag handle, `24.0` wide horizontal screen margins, and side-aligned interactive back/options menus.
- **Ultra-Smooth, Flicker-Free Page Swiping**:
  - Excluded redundant animation set clear actions during horizontal tab changes, ensuring kept-alive viewports retain their entrance staggered animations persistently without visually refreshing, lagging, or causing visual list flickering.
- **Dedicated Premium "Song Info" (Track Details) Modal**:
  - **Clean Separation from Editing**: Developed a dedicated, read-only track info bottom sheet to present audio technical data separately from virtual metadata modification, aligning with professional media player architectures.
  - **Dynamic Audio Identity Card**: Displays a beautifully framed floating card showing the active track artwork, title, artist name, and album.
  - **Color-Adaptive Format Badge**: Evaluates file paths on-the-fly to show a beautiful, high-contrast, rounded badge of the file format (e.g., MP3, FLAC, M4A, WAV) styled dynamically using the application's active accent color.
  - **Asynchronous File Size Resolution**: Computes local file size asynchronously in bytes and formats it into user-friendly `KB` or `MB` readouts.
  - **Monospace Path Copier**: Integrates a clean, system-wrapped `monospace` path visualizer, complete with a quick copy-to-clipboard button and a premium feedback toast.
  - **Seamless Context Transitions**: Includes an elegant outlined button inside the modal to jump instantly to the metadata editor panel if modification is desired, preserving back-stack focus.
- **Full-Scale Flutter Modernization & Zero-Warning Optimization**:
  - **Deprecated API Refactoring**: Swept the entire codebase—including `lib/ui/modals_ui.dart` and `lib/ui/tabs_ui.dart`—replacing the deprecated `.withOpacity(...)` on colors with the modern, high-precision `.withValues(alpha: ...)` API.
  - **Perfect Clean Compilation**: Resolved 28 compiler/analyzer issues in one pass, leaving the codebase pristine, compile-ready, and reporting **`No issues found!`** during active static analysis.
- **Instant & Flicker-Free Tab Jump Navigation**: Upgraded the tab filter pills (Songs, Playlists, Artists, Albums) to use direct `jumpToPage` instant routing and engineered a custom `_KeepAliveWrapper` (`AutomaticKeepAliveClientMixin`) to hold all four viewports persistently in memory. This eliminates all visual refresh flickering, prevents list rebuild lag (0ms switching speed), and perfectly preserves the scroll positions of each tab when navigating back and forth.
- **Elite Staggered List Entrance Animations**: Crafted a custom, physics-based `_FadeInSlideUp` animation widget using lightweight `TweenAnimationBuilders` and memory-safe `Timers`. Applied staggered delayed fading and slide-up entrance animations (350ms duration with `Curves.easeOutCubic`) to all items in the Library (Songs, Playlists, Artists, Albums tabs) and context-sensitive Detail Views. Items animate smoothly as they mount or scroll into view, delivering a gorgeous, premium fluid feel.

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
- **`audio_service`**: OS-level audio session backgrounding and system tray locking controls using MediaSession APIs.
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

- **Android**: Requires `minSdk` 21, `targetSdk` 34 (or higher), and Java 17 for compilation. Note that the project utilizes Flutter's Built-in Kotlin compatibility.
- **iOS**: Requires iOS 12.0 or higher. Note that Swift Package Manager adoption may be required for certain plugins in future updates.

## Development Notes

- When running on Android 13 or higher, ensure that the application is granted the `READ_MEDIA_AUDIO` permission for proper library scanning. The application uses `content://` URIs to support scoped storage natively.
- Make sure to use JDK 17 for compiling the Android build due to updated Kotlin and Gradle Plugin (`build.gradle.kts`) requirements.

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0). See the [LICENSE](LICENSE) file for more details.

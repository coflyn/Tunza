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

## Previous Updates

- **Elite Custom Wallpaper Engines & Dual Wallpaper Editor Suites**:
  - **Sleek Custom Background Engine Refactoring**: Replaced all unstable BackdropFilters with a precise, hardware-accelerated `ImageFiltered` widget wrapped in a `ClipRect`. This completely resolves visual bleeding bugs and performance stutter issues on high-end and budget devices alike, delivering perfect glassmorphic aesthetics.
  - **Premium Theme & Player Background Custom Image Support**: Comprehensive gallery image selection support for both the active Now Playing player background and the global application theme.
  - **Dual Real-Time Wallpaper Editor Dashboards**: Integrated two independent customization suites inside Settings when a Custom Gallery Image is selected for the player or theme:
    - **Interactive Sliders**: Fine-tune **Blur Level (0 to 60 sigma)**, **Dim Level / Opacity (0% to 90%)**, and **Zoom Scale / Cut (1.0x to 3.0x for player, 1.0x to 2.0x for theme)** independently.
    - **Live Miniature Mockup Previews**: Renders real-time, 140x220 rounded mockup cards of the home library grid (for the Theme customizer) and the Now Playing interface (for the Player customizer) inside the Settings dashboard. These mockups dynamically reflect blur, dim, and zoom settings as sliders are dragged, showcasing simulated fonts, accent lines, and list items.
  - **Smart Memory & Offline Persistence**: Automatically caches selected gallery paths and slider configuration values using persistent `SharedPreferences`. Switching visual styles preserves previously selected photos without popping open the system picker again.
  - **Global 3-Choice Theme Modes**: Designed a fully responsive, triple-theme system. A gorgeous, interactive modal sheet in the settings card allows users to transition dynamically between battery-saving **Dark Mode** (`#0A0A0A` scaffold, `#161616` cards), pristine **Light Mode** (`#F6F8FA` scaffold, `#FFFFFF` cards), and **Custom Theme Mode**. Custom theme supports either **Dynamic (Artwork)** color-tint backdrops (calculated mathematically via HSL saturation/lightness bounds), **5 luxury solid color backdrops** (Deep Navy, Forest Green, Midnight Wine, Sunset Terracotta, Slate Gray-Blue), or **Custom Gallery Image Wallpaper**! TextTheme colors, drag grabbers, chevrons, icons, and dialog overlays dynamically shift to guarantee absolute contrast and high-fidelity accessibility.
- **Dynamic Theme Accent System & Real-Time Sync**:
  - **Custom Player Background Styles**: Developed a breathtaking player background visual customizer. Users can choose in settings between three premium background types: **Dynamic Gradient** (our signature dynamic color linear blend), **Apple Blurred Cover** (a massive, magnified version of the active cover art with heavy real-time BackdropFilter glassmorphic blur and dark vignette overlay), and **AMOLED Deep Black** (a solid pure black backdrop for battery saving and ultra-minimalism).
  - **Strict Solid Themes vs. Adaptive Dynamic Artwork**: Completely rebuilt the theme engine to support 9 solid preset accent highlights (Spotify Green (Default), Apple Red, Deep Purple, Tidal Cyan, Sunset Orange, Sakura Pink, Luxury Gold, Sapphire Blue, Electric Lime) alongside an advanced **Dynamic (Artwork)** mode. Solid themes strictly lock visual accents, while Dynamic mode adapts color profiles dynamically based on the active cover art.
  - **New Premium Accent Additions**: Expanded the customization dashboard with three highly-requested, luxury colorway profiles: **Luxury Gold** (warm golden studio feel), **Sapphire Blue** (deep high-fidelity ocean blue), and **Electric Lime** (high-energy neon glowing green).
  - **Monochromatic Grayscale & HSL Contrast Auto-Brightener**: Resolves the "invisible dark colors" accessibility bug. Leverages HSL (Hue, Saturation, Lightness) mathematics to inspect the lightness of extracted dynamic colors. Low-contrast dark colors are dynamically brightened into readable neons/pastels, while low-saturation dark artwork (such as pure black covers) resolves to a gorgeous, premium Silver-Grey (`#B3B3B3`).
  - **Zero-Truncation Interactive Lyrics Layout**: Fixed the critical lyric clipping bug. Swapped fixed item boundaries with fluid `ConstrainedBox` height bounds and discarded `maxLines` and `TextOverflow.ellipsis` clipping rules. Lyrics now dynamically wrap to multiple lines to display complete texts, preventing any words from getting cut off with `...` while maintaining precise center-scrolling timeline sync.
  - **Instant ValueNotifier Real-Time State Propagator**: Connected a highly-efficient `ValueNotifier` color stream directly from the player color generator down to the standalone SettingsScreen. Swapping accent modes or transitioning songs instantly repaints the entire settings panel, switches, sliders, checkmarks, and dialog elements in real-time with zero latency.
  - **Neutral Fallback Aesthetics**: If Dynamic mode is active but no song is currently playing, the application elegantly transitions to a beautiful, minimalist neutral Apple-style system gray (`#8E8E93`) instead of raw green, indicating standby mode.
- **Premium Playlist Editor & Subtitle Total Duration Stats**:
  - **Quick Action Row Integration**: Relocated the Sort button directly next to the Play & Shuffle buttons on all detail screens. Custom user playlists now also feature a beautiful `edit_note` button directly inside the row for instant, high-speed playlist editing.
  - **Advanced Multi-Action Playlist Editor (`_showEditPlaylistSongsModal`)**: Designed a breathtaking modal sheet allowing users to add tracks from the full library (powered by `_showMultiSelectSongsModal`), select/deselect all songs with one tap, and batch-delete multiple selected songs instantly with a secure double-confirmation dialog.
  - **Total Duration Subtitle Statistics**: Tapping any playlist, artist, or album dynamically calculates the sum of all song durations in the view. Displays a beautiful Spotify-style combined subtitle (e.g. `16 songs • 45 min 32 sec` or `16 songs • 1 hr 12 min`) computed asynchronously with zero frame drops.
  - **Alphabetical and Dynamic Pills Sorting**: Integrated global sorting support directly into unique collections under the primary tabs, meaning changing your global sort order dynamically rearranges the unique **Artists** and **Albums** lists based on their newest additions, oldest additions, or durations.
- **Premium Multi-Context Sorting System (Library & Detail Views)**:
  - **Dynamic Independent Context Sorting**: Separated track sorting configurations so that the main Library list (`_sortBy`) and active Detail views like Albums, Artists, or Playlists (`_detailSortBy`) maintain their own independent, custom sort preferences.
  - **Curated Multi-Option Main Sorting Sheet**: Integrates a beautiful glassmorphic "Sort by" bottom sheet for the general library containing options like: *Recently Added (Default)*, *Oldest Added first*, *Title (A to Z)*, *Artist (A to Z)*, *Album (A to Z)*, *Duration (Longest first)*, and *Duration (Shortest first)*.
  - **Context-Specific Album/Detail Sorting**: Added a "Sort Songs" option item inside the detail options bottom sheet that opens a tailored "Sort songs in view" panel. Allows sorting lists independently with an option to restore original track numbers/index via the *Default Track Order* setting.
  - **Real-Time Cache-Invalidated Re-sorting**: Leverages micro-precise state mutations to instantly invalidate active detail page cache keys (`_cachedDetailKey = null`) upon sorting triggers. Ensures that the visual list and underlying playing queue ("Up Next") re-sort and render instantly in real-time.
  - **Persistent SharedPreferences Cache**: Saves both library sorting preference and detail sorting preference in individual offline caches, ensuring custom layout choices remain persistent across restarts.
- **Unified Premium System-Wide Toast UI (`showTunzaToast`)**:
  - **Fluid Consistency**: Replaced standard Android platform toasts with a centralized, premium customized helper function `showTunzaToast`. All alerts, options, playlist updates, and settings modifications are displayed with a bottom-gravity, elegantly styled dark background (`#1E1E1E`), and clean typography to fit Tunza's premium aesthetic.
- **Dynamic Accent-Themed Equalizer**:
  - **Dynamic Visual Adaption**: Upgraded the studio mixing console bottom sheet to automatically and dynamically morph its accent color (mixing sliders, horizontal preset chips, active switch toggles) matching the active song's dominant color palette extracted from album art.
  - **Failsafe Spotify Green Fallback**: Smoothly transitions to iconic Spotify Green (`#1DB954`) when no track is actively playing or when color extraction is not possible.
- **Premium Hybrid Lyrics Engine (Synced LRC & Manual Override)**:
  - **Dynamic LRCLIB API Integration**: Automatically queries the public LRCLIB database using cleaned artist and track parameters to download plain and synchronized LRC lyrics on-the-fly without requiring API keys.
  - **Karaoke-Style Synced Scrolling**: Renders beautiful, glassmorphic synchronized lyrics where the active line lights up and smooth-scrolls to the center in real-time, matched perfectly to the player's millisecond timeline.
  - **Tap-to-Seek Interactive Navigation**: Allows users to tap any line in the synced lyrics panel to instantly seek the audio player to that exact time index.
  - **Manual Editor & Google Search Shortcut**: Spawns a gorgeous, modern manual editor dialog allowing offline editing and saving of lyrics (supporting both plain and LRC formats) cached locally via `SharedPreferences`. Includes a one-click Google search shortcut to easily find, copy, and paste missing lyrics.
- **Real-time 'Check for Updates' (GitHub Releases API Integration)**:
  - **Live Dynamic Fetching**: Replaced static update checks with a fully functional, zero-overhead asynchronous check query querying the official GitHub Releases API (`api.github.com/repos/coflyn/Tunza/releases/latest`) using Dart's native HttpClient.
  - **Material 3 Guided Dialog**: Compares the active semantic version (`1.0.0`) with the repository's latest release tag, prompting the user with a beautiful modern dialog containing version details and a direct redirect download button on newer releases.
- **Auto-Regex Cleaner Library Loop & 3-Dots Equalizer Access**:
  - **Rescan Visual Triggers**: Enabling the titles cleaner under settings now automatically triggers a premium guide toast prompting the user to run a library scan, ensuring existing song titles reflect cleaner titles instantly.
  - **Universal Access Point**: Integrated direct access to the beautiful Equalizer from the 3-dots track settings context menu across all primary music grids (Library and Now Playing panel), completely protected by session safety check guards.
- **Silence Trimmer (Dynamic Silent Gap downskipping)**:
  - **High-Fidelity Waveform Interception**: Leveraged the underlying Android ExoPlayer pipeline within the `just_audio` package to automatically detect and skip silent segments in local audio tracks, offering an uninterrupted, seamless playback flow particularly noticeable in podcasts, live recordings, and classical tracks.
  - **Dynamic Setting Propagator**: Integrated a premium custom preference switch under the Audio & Playback settings card with immediate hardware playback application and SharedPreferences state persistence.
- **Gorgeous Custom Equalizer (Hardware-Accelerated Studio Mixing Console)**:
  - **Breathtaking Custom Studio UI**: Built an incredibly premium, glassmorphic custom Equalizer bottom sheet dashboard inside Tunza. Features **vertical mixing sliders** styled like professional studio consoles, complete with real-time decibel (`dB`) tracking and center frequency labels.
  - **Zero-Latency Hardware Integration**: Leveraged native Kotlin binding (`android.media.audiofx.Equalizer`) using the player's dynamic `audioSessionId` to perform hardware-level DSP audio sculpting with zero CPU overhead or battery drain.
  - **Vibrant Horizontal Preset Chips**: Added support for 11 professional audio presets (_Flat, Classical, Dance, Folk, Heavy Metal, Hip Hop, Jazz, Pop, Rock, Bass Booster_, and _Vocal Booster_) selectable via a responsive horizontal carousel.
  - **Persistent Profile Caching**: Saves the active preset, individual band gains, and enabled state in `SharedPreferences`, automatically restoring and applying the profile to the system card on startup and song changes.
- **Power Saver Mode (Stop Playback on Low Battery)**:
  - **Lightweight System Status Broadcast Receiver**: Developed a battery state method method channel reading Android's `Intent.ACTION_BATTERY_CHANGED` without third-party battery package bloat.
  - **Intelligent Power Level Validation**: Spawns a background timer checking status every 30 seconds. If the active device is playing music, drops below a **15% battery threshold**, and is **not charging**, it automatically pauses playback with our high-fidelity fade out and displays a premium system toast warning ("Battery low. Playback paused.").
- **Mono Audio Toggle (Enhanced System Accessibility Override)**:
  - **Robust OEM Fallback Protection**: Refactored the native access channel to catch `SecurityException` (`SECURE_SETTINGS_RESTRICTED`) when OEMs restrict direct write permissions on modern Android versions, automatically routing the user to Android's accessibility settings.
  - **Adaptive Guided Assist**: Displays a clear, visual guiding Toast: _"Info: Tunza doesn't need to be in 'Downloaded Apps'. Simply toggle the global 'Mono Audio' switch on this screen!"_, removing any confusion about modern accessibility permissions.
- **Dynamic Typography & Font Size Dashboard**:
  - **Premium Typography Alternatives**: Integrated three highly curated, premium sans-serif typeface options from Google Fonts: **Plus Jakarta Sans (Default)**, **Figtree (Spotify Style)**, and **Inter (Apple Music Style)**.
  - **Global Dynamic Text Scaling**: Added a dedicated global text scaler supporting four granular sizes: **Small (85%)**, **Default (100%)**, **Large (115%)**, and **Extra Large (130%)** propagated instantly across the entire application via a root-level custom `MediaQuery` builder.
  - **Live Replica Library Preview**: Designed a breathtaking simulated replica of the Tunza Library directly inside the customization bottom sheet. It simulates the real app bar (with search, palette, and actions), category tabs, track metadata, and rounded artwork placeholders.
  - **Instant Mathematical Real-Time Rendering**: The Live Preview dynamically evaluates typography styles and sizing multipliers, adjusting spacing, layouts, and font scales instantly in real-time as you tap options before saving.
  - **Robust Caching Persistence**: Serializes and stores both the active font family name and font scale double inside `SharedPreferences` to ensure 100% persistent customization across application restarts.
- **Deep Hardware & System Audio Session Controls**:
  - **Become Noisy Earphone Unplug Listener**: Integrated a listener on `session.becomingNoisyEventStream` which automatically pauses the active playback via a smooth crossfade and fires a premium system toast ("Headphones unplugged. Paused.") when wired or Bluetooth headphones are disconnected.
  - **Call Interruption Auto-Resume**: Configured focus interruption listening. The audio player ducks to 20% volume on duck interruptions, pauses on phone calls, and intelligently resumes playing with a clean fade-in once the call ends if music was active before the interruption.
  - **Audio & Playback Preference Switches**: Added premium custom switches for "Pause on Disconnect" and "Resume after Call" inside the settings screen to easily configure system behaviors.
- **Configurable Play Count Threshold for Most Played Statistics**:
  - **Flexible Statistics Thresholds**: Added a customizable play count threshold tile under Settings. Users can select how long a song must be played before it registers inside the "Most Played" list: **5 seconds**, **10 seconds (Default)**, **30 seconds**, **1 minute**, or **End of track**.
  - **Dynamic Stream Validation**: Connected the preference seamlessly with the underlying stream listeners, qualifying plays dynamically without registering duplicate increments on seeking or pausing.
- **Advanced Dynamic In-Place Crossfade & Sliding Queue Engine**:
  - **Custom Studio-Grade Crossfade Transitions**: Completely revamped the 200ms - 3000ms transition engine (with a premium 200ms default). Manual track changes (tapping songs, skip forwards, skip backwards) now execute mathematically perfect volume fading curves to avoid crackles, clicks, and sudden waveform clipping pops.
  - **Seamless Native Transitions**: Integrates a micro-precise listener on the `positionStream`. If crossfade is active and Repeat One is disabled, it automatically kicks in a smooth volume fade-out exactly at the specified duration (up to 3000ms) before the track naturally finishes, allowing the player to transition natively to the next song without forced programmatic skipping or double-skip bugs.
  - **Zero-Latency In-Place Window Sliding & Fade-In**: Coupled volume fade-in directly inside `_slideWindowInPlace` to perform a smooth, hardware-level volume recovery curve over the crossfade duration. This ensures all UI parameters (title, cover, colors, lyrics) update immediately at the exact millisecond of transition, preserving absolute gapless state sync and eliminating restart loops.
  - **Dynamic In-Place Mutation (Zero Audio Interruptions)**: Solved the infamous "sliding window restart" bug. The underlying 3-track sliding queue (`[Previous, Current, Next]`) is now dynamically mutated inside the active player's `ConcatenatingAudioSource` memory structure using asynchronous `removeAt()` and `add()` methods. Natural track changes now transition gaplessly and flawlessly, without ever triggering hard reloads or forcing the next track to start over from the 0th second.

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

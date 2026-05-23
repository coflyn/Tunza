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
  - **Lightweight System Status Broadcast Receiver**: Developed a battery state method channel reading Android's `Intent.ACTION_BATTERY_CHANGED` without third-party battery package bloat.
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

## Previous Updates

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

// Flow Localization System
// Supports: English (en), Indonesian (id), Japanese (ja)
//
// Usage: FlowStrings.get('library')

import 'package:flutter/material.dart';

final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');

class FlowStrings {
  static String get currentLang => languageNotifier.value;

  static String get(String key) {
    final lang = languageNotifier.value;
    return _strings[key]?[lang] ?? _strings[key]?['en'] ?? key;
  }

  static const Map<String, Map<String, String>> _strings = {
    // Tab Header
    'library': {'en': 'Library', 'id': 'Perpustakaan', 'ja': 'ライブラリ'},
    'playlists': {'en': 'Playlists', 'id': 'Playlist', 'ja': 'プレイリスト'},
    'artists': {'en': 'Artists', 'id': 'Artis', 'ja': 'アーティスト'},
    'albums': {'en': 'Albums', 'id': 'Album', 'ja': 'アルバム'},

    // Search
    'search_songs': {
      'en': 'Search songs, artists, albums...',
      'id': 'Cari lagu, artis, album...',
      'ja': '曲、アーティスト、アルバムを検索...',
    },
    'no_results': {
      'en': 'No results found',
      'id': 'Tidak ada hasil',
      'ja': '結果が見つかりません',
    },

    // Empty States
    'no_songs_found': {
      'en': 'No Local Songs Found',
      'id': 'Tidak Ada Lagu Lokal',
      'ja': 'ローカルの曲が見つかりません',
    },
    'no_songs_subtitle': {
      'en':
          'Copy some audio files to your device storage and refresh the page.',
      'id':
          'Salin beberapa file audio ke penyimpanan perangkat lalu muat ulang halaman.',
      'ja': 'オーディオファイルをデバイスのストレージにコピーして、ページを更新してください。',
    },
    'refresh_library': {
      'en': 'Refresh Library',
      'id': 'Muat Ulang',
      'ja': 'ライブラリを更新',
    },

    // Smart Playlists
    'favourites': {'en': 'Favourites', 'id': 'Favorit', 'ja': 'お気に入り'},
    'recently_added': {
      'en': 'Recently Added',
      'id': 'Baru Ditambahkan',
      'ja': '最近追加',
    },
    'last_played': {
      'en': 'Last Played',
      'id': 'Terakhir Diputar',
      'ja': '最近再生',
    },
    'most_played': {
      'en': 'Most Played',
      'id': 'Paling Sering Diputar',
      'ja': 'よく再生する曲',
    },
    'songs_count': {'en': 'songs', 'id': 'lagu', 'ja': '曲'},

    // Player Ui
    'playing_from': {'en': 'PLAYING FROM', 'id': 'DIPUTAR DARI', 'ja': '再生元'},
    'all_songs': {'en': 'All Songs', 'id': 'Semua Lagu', 'ja': 'すべての曲'},
    'up_next': {'en': 'Up Next', 'id': 'Selanjutnya', 'ja': '次へ'},
    'lyrics': {'en': 'Lyrics', 'id': 'Lirik', 'ja': '歌詞'},
    'no_lyrics': {
      'en': 'No lyrics available',
      'id': 'Lirik tidak tersedia',
      'ja': '歌詞がありません',
    },

    // Track Options
    'add_to_playlist': {
      'en': 'Add to Playlist',
      'id': 'Tambah ke Playlist',
      'ja': 'プレイリストに追加',
    },
    'remove_from_playlist': {
      'en': 'Remove from Playlist',
      'id': 'Hapus dari Playlist',
      'ja': 'プレイリストから削除',
    },
    'add_to_favourites': {
      'en': 'Add to Favourites',
      'id': 'Tambah ke Favorit',
      'ja': 'お気に入りに追加',
    },
    'remove_from_favourites': {
      'en': 'Remove from Favourites',
      'id': 'Hapus dari Favorit',
      'ja': 'お気に入りから削除',
    },
    'play_next': {'en': 'Play Next', 'id': 'Putar Selanjutnya', 'ja': '次に再生'},
    'add_to_queue': {
      'en': 'Add to Queue',
      'id': 'Tambah ke Antrian',
      'ja': 'キューに追加',
    },
    'edit_metadata': {
      'en': 'Edit Metadata',
      'id': 'Edit Metadata',
      'ja': 'メタデータを編集',
    },
    'hide_track': {'en': 'Hide Track', 'id': 'Sembunyikan Lagu', 'ja': '曲を非表示'},
    'share': {'en': 'Share', 'id': 'Bagikan', 'ja': '共有'},

    // Playlist Management
    'create_playlist': {
      'en': 'Create Playlist',
      'id': 'Buat Playlist',
      'ja': 'プレイリストを作成',
    },
    'new_playlist': {
      'en': 'New Playlist',
      'id': 'Playlist Baru',
      'ja': '新しいプレイリスト',
    },
    'playlist_name': {
      'en': 'Playlist Name',
      'id': 'Nama Playlist',
      'ja': 'プレイリスト名',
    },
    'rename_playlist': {
      'en': 'Rename Playlist',
      'id': 'Ubah Nama Playlist',
      'ja': 'プレイリスト名を変更',
    },
    'delete_playlist': {
      'en': 'Delete Playlist',
      'id': 'Hapus Playlist',
      'ja': 'プレイリストを削除',
    },
    'delete_playlist_confirm': {
      'en': 'Are you sure you want to delete this playlist?',
      'id': 'Apakah kamu yakin ingin menghapus playlist ini?',
      'ja': 'このプレイリストを削除してもよろしいですか？',
    },

    // Metadata Editor
    'title': {'en': 'Title', 'id': 'Judul', 'ja': 'タイトル'},
    'artist': {'en': 'Artist', 'id': 'Artis', 'ja': 'アーティスト'},
    'album': {'en': 'Album', 'id': 'Album', 'ja': 'アルバム'},
    'save': {'en': 'Save', 'id': 'Simpan', 'ja': '保存'},
    'reset': {'en': 'Reset', 'id': 'Reset', 'ja': 'リセット'},
    'cancel': {'en': 'Cancel', 'id': 'Batal', 'ja': 'キャンセル'},
    'delete': {'en': 'Delete', 'id': 'Hapus', 'ja': '削除'},
    'close': {'en': 'Close', 'id': 'Tutup', 'ja': '閉じる'},
    'done': {'en': 'Done', 'id': 'Selesai', 'ja': '完了'},
    'confirm': {'en': 'Confirm', 'id': 'Konfirmasi', 'ja': '確認'},

    // Settings: Section Headers
    'settings': {'en': 'Settings', 'id': 'Pengaturan', 'ja': '設定'},
    'appearance': {'en': 'Appearance', 'id': 'Tampilan', 'ja': '外観'},
    'audio_playback': {
      'en': 'Audio & Playback',
      'id': 'Audio & Pemutaran',
      'ja': 'オーディオと再生',
    },
    'library_storage': {
      'en': 'Library & Storage',
      'id': 'Perpustakaan & Penyimpanan',
      'ja': 'ライブラリとストレージ',
    },
    'about_flow': {'en': 'About Flow', 'id': 'Tentang Flow', 'ja': 'Flowについて'},

    // Settings: Appearance
    'language': {'en': 'Language', 'id': 'Bahasa', 'ja': '言語'},
    'language_en': {'en': 'English', 'id': 'English', 'ja': '英語'},
    'language_id': {'en': 'Indonesian', 'id': 'Indonesia', 'ja': 'インドネシア語'},
    'language_ja': {'en': 'Japanese', 'id': 'Jepang', 'ja': '日本語'},
    'language_subtitle': {
      'en': 'Change app display language',
      'id': 'Ubah bahasa tampilan aplikasi',
      'ja': 'アプリの表示言語を変更します',
    },
    'typography_font_size': {
      'en': 'Typography & Font Size',
      'id': 'Tipografi & Ukuran Font',
      'ja': 'タイポグラフィとフォントサイズ',
    },
    'theme_accent_color': {
      'en': 'Theme Accent Color',
      'id': 'Warna Aksen Tema',
      'ja': 'テーマのアクセントカラー',
    },
    'theme_mode': {'en': 'Theme Mode', 'id': 'Mode Tema', 'ja': 'テーマモード'},
    'dark_mode': {'en': 'Dark Mode', 'id': 'Mode Gelap', 'ja': 'ダークモード'},
    'light_mode': {'en': 'Light Mode', 'id': 'Mode Terang', 'ja': 'ライトモード'},
    'custom_theme': {
      'en': 'Custom Theme',
      'id': 'Tema Kustom',
      'ja': 'カスタムテーマ',
    },
    'accent_color': {
      'en': 'Accent Color',
      'id': 'Warna Aksen',
      'ja': 'アクセントカラー',
    },
    'font_style': {'en': 'Font Style', 'id': 'Gaya Font', 'ja': 'フォントスタイル'},
    'font_size': {'en': 'Font Size', 'id': 'Ukuran Font', 'ja': 'フォントサイズ'},
    'font_family': {
      'en': 'Font Family',
      'id': 'Keluarga Font',
      'ja': 'フォントファミリー',
    },
    'size_small': {'en': 'Small', 'id': 'Kecil', 'ja': '小'},
    'size_default': {'en': 'Default', 'id': 'Default', 'ja': 'デフォルト'},
    'size_large': {'en': 'Large', 'id': 'Besar', 'ja': '大'},
    'size_extra_large': {'en': 'Extra Large', 'id': 'Sangat Besar', 'ja': '特大'},
    'live_preview': {
      'en': 'Live Preview',
      'id': 'Pratinjau Langsung',
      'ja': 'ライブプレビュー',
    },
    'accent_spotify': {
      'en': 'Spotify Green',
      'id': 'Hijau Spotify',
      'ja': 'Spotify グリーン',
    },
    'accent_apple': {'en': 'Apple Red', 'id': 'Merah Apple', 'ja': 'Apple レッド'},
    'accent_purple': {'en': 'Deep Purple', 'id': 'Ungu Tua', 'ja': 'ディープパープル'},
    'accent_tidal': {'en': 'Tidal Cyan', 'id': 'Sian Tidal', 'ja': 'Tidal シアン'},
    'accent_orange': {
      'en': 'Sunset Orange',
      'id': 'Oranye Senja',
      'ja': 'サンセットオレンジ',
    },
    'accent_sakura': {
      'en': 'Sakura Pink',
      'id': 'Merah Muda Sakura',
      'ja': 'サクラピンク',
    },
    'accent_gold': {
      'en': 'Luxury Gold',
      'id': 'Emas Mewah',
      'ja': 'ラグジュアリーゴールド',
    },
    'accent_blue': {
      'en': 'Sapphire Blue',
      'id': 'Biru Safir',
      'ja': 'サファイアブルー',
    },
    'accent_lime': {
      'en': 'Electric Lime',
      'id': 'Kuning Jeruk Elektrik',
      'ja': 'エレクトリックライム',
    },
    'theme_background': {
      'en': 'Theme Background',
      'id': 'Latar Belakang Tema',
      'ja': 'テーマの背景',
    },
    'player_background': {
      'en': 'Player Background Style',
      'id': 'Gaya Latar Pemutar',
      'ja': 'プレーヤーの背景スタイル',
    },
    'theme_wallpaper_settings': {
      'en': 'Theme Wallpaper Settings',
      'id': 'Pengaturan Wallpaper Tema',
      'ja': 'テーマ壁紙設定',
    },
    'wallpaper_settings': {
      'en': 'Wallpaper Settings',
      'id': 'Pengaturan Wallpaper',
      'ja': '壁紙の設定',
    },
    'change_photo': {'en': 'Change Photo', 'id': 'Ganti Foto', 'ja': '写真を変更'},
    'blur_level': {'en': 'Blur Level', 'id': 'Tingkat Blur', 'ja': 'ぼかしレベル'},
    'dim_level': {'en': 'Dim Level', 'id': 'Tingkat Redup', 'ja': '暗さレベル'},
    'zoom_scale': {'en': 'Zoom Scale', 'id': 'Skala Zoom', 'ja': 'ズームスケール'},
    'pan_horizontal': {
      'en': 'Pan Horizontal (X)',
      'id': 'Geser Horizontal (X)',
      'ja': '水平パン (X)',
    },
    'pan_vertical': {
      'en': 'Pan Vertical (Y)',
      'id': 'Geser Vertikal (Y)',
      'ja': '垂直パン (Y)',
    },
    'no_wallpaper': {
      'en':
          'No custom wallpaper selected.\nTap "Change Photo" to pick one from gallery!',
      'id':
          'Belum ada wallpaper kustom.\nKetuk "Ganti Foto" untuk memilih dari galeri!',
      'ja': 'カスタム壁紙が選択されていません。\n「写真を変更」をタップしてギャラリーから選択してください！',
    },

    // Settings: Theme Background Options
    'dynamic_artwork': {
      'en': 'Dynamic (Artwork)',
      'id': 'Dinamis (Artwork)',
      'ja': 'ダイナミック (アートワーク)',
    },
    'deep_navy': {'en': 'Deep Navy', 'id': 'Biru Tua', 'ja': 'ディープネイビー'},
    'forest_green': {
      'en': 'Forest Green',
      'id': 'Hijau Hutan',
      'ja': 'フォレストグリーン',
    },
    'midnight_wine': {
      'en': 'Midnight Wine',
      'id': 'Anggur Malam',
      'ja': 'ミッドナイトワイン',
    },
    'sunset_terracotta': {
      'en': 'Sunset Terracotta',
      'id': 'Terakota Senja',
      'ja': 'サンセットテラコッタ',
    },
    'slate_gray_blue': {
      'en': 'Slate Gray-Blue',
      'id': 'Abu Biru Batu',
      'ja': 'スレートグレーブルー',
    },
    'custom_gallery': {
      'en': 'Custom Gallery Image',
      'id': 'Gambar Galeri Kustom',
      'ja': 'カスタムギャラリー画像',
    },

    // Settings: Player Background Options
    'gradient_dynamic': {
      'en': 'Dynamic Gradient',
      'id': 'Gradien Dinamis',
      'ja': 'ダイナミックグラデーション',
    },
    'blurred_cover': {
      'en': 'Apple Blurred Cover',
      'id': 'Cover Blur Apple',
      'ja': 'Appleのぼかしカバー',
    },
    'amoled_black': {
      'en': 'AMOLED Deep Black',
      'id': 'AMOLED Hitam Pekat',
      'ja': 'AMOLEDディープブラック',
    },
    'custom_image': {
      'en': 'Custom Gallery Image',
      'id': 'Gambar Galeri Kustom',
      'ja': 'カスタムギャラリー画像',
    },

    // Settings: Audio & Playback
    'sleep_timer': {'en': 'Sleep Timer', 'id': 'Timer Tidur', 'ja': 'スリープタイマー'},
    'sleep_timer_subtitle': {
      'en': 'Stop audio after a set time',
      'id': 'Hentikan audio setelah waktu tertentu',
      'ja': '設定時間後にオーディオを停止します',
    },
    'stops_in': {'en': 'Stops in', 'id': 'Berhenti dalam', 'ja': '停止まで'},
    'audio_crossfade': {
      'en': 'Audio Crossfade',
      'id': 'Crossfade Audio',
      'ja': 'オーディオクロスフェード',
    },
    'pause_on_disconnect': {
      'en': 'Pause on Disconnect',
      'id': 'Jeda saat Terputus',
      'ja': '切断時に一時停止',
    },
    'pause_on_disconnect_subtitle': {
      'en': 'Pause music when headphones are removed',
      'id': 'Jeda musik saat headphone dicabut',
      'ja': 'ヘッドフォンを外したときに音楽を一時停止します',
    },
    'resume_after_call': {
      'en': 'Resume after Call',
      'id': 'Lanjutkan setelah Panggilan',
      'ja': '通話後に再開',
    },
    'resume_after_call_subtitle': {
      'en': 'Auto play music when a call ends',
      'id': 'Putar otomatis setelah panggilan selesai',
      'ja': '通話終了時に音楽を自動再生します',
    },
    'play_together': {
      'en': 'Play Together with other Apps',
      'id': 'Putar Bersamaan dengan Aplikasi Lain',
      'ja': '他のアプリと一緒に再生',
    },
    'play_together_subtitle': {
      'en': 'Allow Flow to play audio alongside other apps',
      'id': 'Izinkan Flow memutar audio bersamaan dengan aplikasi lain',
      'ja': 'Flowが他のアプリと一緒にオーディオを再生できるようにします',
    },
    'silence_trimmer': {
      'en': 'Silence Trimmer',
      'id': 'Pemotong Senyap',
      'ja': 'サイレンストリマー',
    },
    'silence_trimmer_subtitle': {
      'en': 'Skip truly silent sections (no sound at all)',
      'id': 'Lewati bagian yang benar-benar senyap (tanpa suara sama sekali)',
      'ja': '完全に無音のセクション（音が全くない）をスキップします',
    },
    'stop_on_low_battery': {
      'en': 'Stop Playback on Low Battery',
      'id': 'Hentikan saat Baterai Rendah',
      'ja': 'バッテリー低下時に再生を停止',
    },
    'stop_on_low_battery_subtitle': {
      'en': 'Pause music when battery falls below 15%',
      'id': 'Jeda musik saat baterai di bawah 15%',
      'ja': 'バッテリーが15%を下回ったときに音楽を一時停止します',
    },
    'mono_audio': {
      'en': 'Mono Audio Toggle',
      'id': 'Audio Mono',
      'ja': 'モノラルオーディオ',
    },
    'mono_audio_subtitle': {
      'en': 'Combine left and right audio channels',
      'id': 'Gabungkan saluran audio kiri dan kanan',
      'ja': '左右のオーディオチャンネルを結合します',
    },
    'equalizer': {'en': 'Equalizer', 'id': 'Equalizer', 'ja': 'イコライザー'},
    'equalizer_subtitle': {
      'en': 'Adjust sound effects and audio frequency',
      'id': 'Sesuaikan efek suara dan frekuensi audio',
      'ja': '効果音とオーディオ周波数を調整します',
    },
    'most_played_threshold': {
      'en': 'Most Played Threshold',
      'id': 'Ambang Paling Sering Diputar',
      'ja': 'よく再生する曲のしきい値',
    },

    // Settings: Library & Storage
    'auto_regex_cleaner': {
      'en': 'Auto Regex Cleaner',
      'id': 'Pembersih Judul Otomatis',
      'ja': '自動正規表現クリーナー',
    },
    'auto_regex_subtitle': {
      'en': 'Automatically clean messy song titles',
      'id': 'Bersihkan judul lagu yang berantakan secara otomatis',
      'ja': '乱雑な曲のタイトルを自動的にクリーンアップします',
    },
    'filter_short_audio': {
      'en': 'Filter Short Audio',
      'id': 'Filter Audio Pendek',
      'ja': '短いオーディオをフィルタリング',
    },
    'filter_short_subtitle': {
      'en': 'Hide tracks shorter than 30 seconds',
      'id': 'Sembunyikan lagu yang kurang dari 30 detik',
      'ja': '30秒未満の曲を非表示にします',
    },
    'specific_folder_scan': {
      'en': 'Specific Folder Scan',
      'id': 'Pindai Folder Tertentu',
      'ja': '特定のフォルダをスキャン',
    },
    'specific_folder_subtitle': {
      'en': 'Only scan specific directories',
      'id': 'Hanya pindai direktori tertentu',
      'ja': '特定のディレクトリのみをスキャンします',
    },
    'hidden_tracks': {
      'en': 'Hidden Tracks',
      'id': 'Lagu Tersembunyi',
      'ja': '非表示の曲',
    },
    'hidden_tracks_subtitle': {
      'en': 'Manage hidden and filtered tracks',
      'id': 'Kelola lagu yang disembunyikan dan difilter',
      'ja': '非表示またはフィルタリングされた曲を管理します',
    },
    'rescan_library': {
      'en': 'Rescan Library',
      'id': 'Pindai Ulang Perpustakaan',
      'ja': 'ライブラリを再スキャン',
    },
    'rescan_subtitle': {
      'en': 'Search for new audio files on your device',
      'id': 'Cari file audio baru di perangkat',
      'ja': 'デバイスで新しいオーディオファイルを検索します',
    },
    'clear_image_cache': {
      'en': 'Clear Image Cache',
      'id': 'Hapus Cache Gambar',
      'ja': '画像キャッシュをクリア',
    },
    'clear_cache_subtitle': {
      'en': 'Free up memory used by album covers',
      'id': 'Bebaskan memori yang dipakai cover album',
      'ja': 'アルバムカバーが使用しているメモリを解放します',
    },
    'backup_data': {
      'en': 'Backup App Data',
      'id': 'Cadangkan Data Aplikasi',
      'ja': 'アプリデータをバックアップ',
    },
    'backup_data_subtitle': {
      'en': 'Save playlists, stats, and settings to Downloads',
      'id': 'Simpan playlist, statistik, dan setelan ke Downloads',
      'ja': 'プレイリスト、統計、設定をダウンロードに保存',
    },
    'restore_data': {
      'en': 'Restore App Data',
      'id': 'Pulihkan Data Aplikasi',
      'ja': 'アプリデータを復元',
    },
    'restore_data_subtitle': {
      'en': 'Restore data from a backup file',
      'id': 'Pulihkan data dari file cadangan',
      'ja': 'バックアップファイルからデータを復元',
    },
    'backup_success': {
      'en': 'Backup saved to Downloads/Flow_Backup.json',
      'id': 'Cadangan disimpan ke Downloads/Flow_Backup.json',
      'ja': 'バックアップをDownloads/Flow_Backup.jsonに保存しました',
    },
    'backup_failed': {
      'en': 'Failed to save backup',
      'id': 'Gagal menyimpan cadangan',
      'ja': 'バックアップの保存に失敗しました',
    },
    'restore_success': {
      'en': 'Data restored successfully',
      'id': 'Data berhasil dipulihkan',
      'ja': 'データの復元に成功しました',
    },
    'restore_failed': {
      'en': 'Failed to restore data (File not found or invalid)',
      'id': 'Gagal memulihkan data (File tidak ditemukan/tidak valid)',
      'ja': 'データの復元に失敗しました（ファイルが見つからないか無効です）',
    },
    'reset_app_data': {
      'en': 'Reset App Data',
      'id': 'Reset Data Aplikasi',
      'ja': 'アプリデータをリセット',
    },
    'reset_data_subtitle': {
      'en': 'Clear all playlists, favorites, and history',
      'id': 'Hapus semua playlist, favorit, dan riwayat',
      'ja': 'すべてのプレイリスト、お気に入り、履歴をクリアします',
    },

    // Settings: About
    'check_updates': {
      'en': 'Check for Updates',
      'id': 'Cek Pembaruan',
      'ja': '更新を確認',
    },
    'source_code': {'en': 'Source Code', 'id': 'Kode Sumber', 'ja': 'ソースコード'},
    'github_repo': {
      'en': 'GitHub Repository',
      'id': 'Repositori GitHub',
      'ja': 'GitHub リポジトリ',
    },
    'support_developer': {
      'en': 'Support Developer',
      'id': 'Dukung Pengembang',
      'ja': '開発者を支援',
    },
    'donate_sociabuzz': {
      'en': 'Donate via Sociabuzz',
      'id': 'Donasi via Sociabuzz',
      'ja': 'Sociabuzz で寄付',
    },

    // Toasts / Messages
    'headphones_unplugged': {
      'en': 'Headphones unplugged. Paused.',
      'id': 'Headphone dicabut. Dijeda.',
      'ja': 'ヘッドフォンが外されました。一時停止しました。',
    },
    'play_song_first_eq': {
      'en': 'Please play a song first to use the Equalizer!',
      'id': 'Putar lagu terlebih dahulu untuk menggunakan Equalizer!',
      'ja': 'イコライザーを使用するには、まず曲を再生してください！',
    },
    'battery_low': {
      'en': 'Battery low. Playback paused.',
      'id': 'Baterai rendah. Pemutaran dijeda.',
      'ja': 'バッテリーが低下しています。再生を一時停止しました。',
    },
    'app_data_reset': {
      'en': 'App data has been reset.',
      'id': 'Data aplikasi telah direset.',
      'ja': 'アプリデータがリセットされました。',
    },
    'image_cache_cleared': {
      'en': 'Image cache cleared',
      'id': 'Cache gambar dihapus',
      'ja': '画像キャッシュがクリアされました',
    },
    'wallpaper_updated': {
      'en': 'Custom wallpaper background updated!',
      'id': 'Wallpaper kustom diperbarui!',
      'ja': 'カスタム壁紙が更新されました！',
    },
    'rescan_to_apply': {
      'en': 'Rescan library to apply title cleaning to existing songs',
      'id': 'Pindai ulang perpustakaan untuk menerapkan pembersihan judul',
      'ja': '既存の曲にタイトルのクリーンアップを適用するには、ライブラリを再スキャンしてください',
    },
    'added_to_favourites': {
      'en': 'Added to Favourites',
      'id': 'Ditambahkan ke Favorit',
      'ja': 'お気に入りに追加しました',
    },
    'removed_from_favourites': {
      'en': 'Removed from Favourites',
      'id': 'Dihapus dari Favorit',
      'ja': 'お気に入りから削除しました',
    },
    'added_to_queue': {
      'en': 'Added to queue',
      'id': 'Ditambahkan ke antrian',
      'ja': 'キューに追加しました',
    },
    'will_play_next': {
      'en': 'Will play next',
      'id': 'Akan diputar selanjutnya',
      'ja': '次に再生します',
    },
    'track_hidden': {
      'en': 'Track hidden',
      'id': 'Lagu disembunyikan',
      'ja': '曲を非表示にしました',
    },
    'playlist_created': {
      'en': 'Playlist created',
      'id': 'Playlist dibuat',
      'ja': 'プレイリストを作成しました',
    },
    'playlist_deleted': {
      'en': 'Playlist deleted',
      'id': 'Playlist dihapus',
      'ja': 'プレイリストを削除しました',
    },
    'added_to_playlist': {
      'en': 'Added to playlist',
      'id': 'Ditambahkan ke playlist',
      'ja': 'プレイリストに追加しました',
    },
    'metadata_saved': {
      'en': 'Metadata saved',
      'id': 'Metadata disimpan',
      'ja': 'メタデータを保存しました',
    },
    'metadata_reset': {
      'en': 'Metadata reset to original',
      'id': 'Metadata dikembalikan ke aslinya',
      'ja': 'メタデータを元にリセットしました',
    },
    'could_not_open_link': {
      'en': 'Could not open link',
      'id': 'Tidak bisa membuka tautan',
      'ja': 'リンクを開けませんでした',
    },
    'flow_up_to_date': {
      'en': 'Flow is up to date!',
      'id': 'Flow sudah versi terbaru!',
      'ja': 'Flow は最新です！',
    },
    'update_available': {
      'en': 'Update Available!',
      'id': 'Pembaruan Tersedia!',
      'ja': '利用可能なアップデートがあります！',
    },
    'new_version_available': {
      'en': 'A new version of Flow is available.',
      'id': 'Versi terbaru Flow tersedia.',
      'ja': '新しいバージョンの Flow が利用可能です。',
    },
    'download': {'en': 'Download', 'id': 'Unduh', 'ja': 'ダウンロード'},
    'later': {'en': 'Later', 'id': 'Nanti', 'ja': '後で'},
    'unable_check_updates': {
      'en': 'Unable to check for updates',
      'id': 'Tidak bisa cek pembaruan',
      'ja': 'アップデートを確認できません',
    },
    'network_error': {
      'en': 'Network error checking for updates',
      'id': 'Kesalahan jaringan saat cek pembaruan',
      'ja': 'アップデート確認中のネットワークエラー',
    },
    'checking_updates': {
      'en': 'Checking for updates...',
      'id': 'Mengecek pembaruan...',
      'ja': 'アップデートを確認しています...',
    },

    // Notification / Dialog
    'notification_required': {
      'en': 'Notification Required',
      'id': 'Notifikasi Diperlukan',
      'ja': '通知が必要です',
    },
    'notification_message': {
      'en':
          "Flow needs the Notification permission to show music playback controls on your lock screen and background.\n\nPlease enable Notifications for Flow in your phone's App Settings.",
      'id':
          "Flow membutuhkan izin Notifikasi untuk menampilkan kontrol musik di layar kunci dan latar belakang.\n\nSilakan aktifkan Notifikasi untuk Flow di Pengaturan Aplikasi.",
      'ja':
          "ロック画面やバックグラウンドで音楽の再生コントロールを表示するには、通知の権限が必要です。\n\n携帯電話のアプリ設定で Flow の通知を有効にしてください。",
    },
    'open_settings': {
      'en': 'OPEN SETTINGS',
      'id': 'BUKA PENGATURAN',
      'ja': '設定を開く',
    },
    'background_audio_error': {
      'en': 'Background Audio Error',
      'id': 'Kesalahan Audio Latar',
      'ja': 'バックグラウンドオーディオエラー',
    },

    // Sleep Timer
    'minutes_15': {'en': '15 Minutes', 'id': '15 Menit', 'ja': '15 分'},
    'minutes_30': {'en': '30 Minutes', 'id': '30 Menit', 'ja': '30 分'},
    'minutes_60': {'en': '60 Minutes', 'id': '60 Menit', 'ja': '60 分'},
    'end_of_track': {
      'en': 'End of Current Track',
      'id': 'Akhir Lagu Saat Ini',
      'ja': '現在の曲の終了時',
    },
    'custom_time': {'en': 'Custom', 'id': 'Kustom', 'ja': 'カスタム'},

    // Sort Options
    'sort_by': {'en': 'Sort by', 'id': 'Urutkan', 'ja': '並べ替え'},
    'sort_date': {'en': 'Date Added', 'id': 'Tanggal Ditambahkan', 'ja': '追加日'},
    'sort_title': {
      'en': 'Title (A-Z)',
      'id': 'Judul (A-Z)',
      'ja': 'タイトル (A-Z)',
    },
    'sort_artist': {
      'en': 'Artist (A-Z)',
      'id': 'Artis (A-Z)',
      'ja': 'アーティスト (A-Z)',
    },
    'sort_duration': {'en': 'Duration', 'id': 'Durasi', 'ja': '時間'},

    // Detail View
    'shuffle_all': {'en': 'Shuffle All', 'id': 'Acak Semua', 'ja': 'すべてシャッフル'},
    'play_all': {'en': 'Play All', 'id': 'Putar Semua', 'ja': 'すべて再生'},

    // Reset Confirmation
    'reset_confirm_title': {
      'en': 'Reset All Data?',
      'id': 'Reset Semua Data?',
      'ja': 'すべてのデータをリセットしますか？',
    },
    'reset_confirm_message': {
      'en':
          'This will permanently clear all your playlists, favorites, play history, metadata edits, and settings. This action cannot be undone.',
      'id':
          'Ini akan menghapus semua playlist, favorit, riwayat putar, edit metadata, dan pengaturan secara permanen. Tindakan ini tidak bisa dibatalkan.',
      'ja':
          'これにより、すべてのプレイリスト、お気に入り、再生履歴、メタデータの編集、および設定が完全にクリアされます。この操作は元に戻せません。',
    },

    // Font Options
    'font_default': {
      'en': 'Plus Jakarta Sans (Default)',
      'id': 'Plus Jakarta Sans (Default)',
      'ja': 'Plus Jakarta Sans (デフォルト)',
    },
    'font_spotify': {
      'en': 'Spotify Style',
      'id': 'Gaya Spotify',
      'ja': 'Spotify スタイル',
    },
    'font_apple': {
      'en': 'Apple Music Style',
      'id': 'Gaya Apple Music',
      'ja': 'Apple Music スタイル',
    },

    // Accent Presets
    'accent_dynamic': {
      'en': 'Dynamic (Artwork)',
      'id': 'Dinamis (Artwork)',
      'ja': 'ダイナミック (アートワーク)',
    },
    'accent_spotify_green': {
      'en': 'Spotify Green',
      'id': 'Hijau Spotify',
      'ja': 'Spotify グリーン',
    },
    'accent_apple_red': {
      'en': 'Apple Red',
      'id': 'Merah Apple',
      'ja': 'Apple レッド',
    },
    'accent_deep_purple': {
      'en': 'Deep Purple',
      'id': 'Ungu Tua',
      'ja': 'ディープパープル',
    },
    'accent_tidal_cyan': {
      'en': 'Tidal Cyan',
      'id': 'Cyan Tidal',
      'ja': 'Tidal シアン',
    },
    'accent_sunset_orange': {
      'en': 'Sunset Orange',
      'id': 'Oranye Senja',
      'ja': 'サンセットオレンジ',
    },
    'accent_sakura_pink': {
      'en': 'Sakura Pink',
      'id': 'Pink Sakura',
      'ja': 'サクラピンク',
    },
    'accent_luxury_gold': {
      'en': 'Luxury Gold',
      'id': 'Emas Mewah',
      'ja': 'ラグジュアリーゴールド',
    },
    'accent_sapphire_blue': {
      'en': 'Sapphire Blue',
      'id': 'Biru Safir',
      'ja': 'サファイアブルー',
    },
    'accent_electric_lime': {
      'en': 'Electric Lime',
      'id': 'Hijau Limau',
      'ja': 'エレクトリックライム',
    },

    // Threshold Options
    'threshold_full_song': {
      'en': 'Full Song',
      'id': 'Lagu Penuh',
      'ja': 'フルソング',
    },
    'threshold_seconds': {'en': 'seconds', 'id': 'detik', 'ja': '秒'},

    // Mono Audio Toasts
    'mono_info_toast': {
      'en':
          "Info: Flow doesn't need to be in 'Downloaded Apps'. Simply toggle the global 'Mono Audio' switch on this screen!",
      'id':
          "Info: Flow tidak perlu di 'Aplikasi Terunduh'. Cukup aktifkan 'Audio Mono' di layar ini!",
      'ja': "情報: Flow を「ダウンロード済みアプリ」に含める必要はありません。この画面で「モノラルオーディオ」を切り替えるだけです！",
    },
    'mono_permission_toast': {
      'en':
          'Please grant Flow permission to modify system settings to toggle Mono Audio',
      'id':
          'Berikan izin Flow untuk mengubah pengaturan sistem untuk Audio Mono',
      'ja': 'モノラルオーディオを切り替えるには、システム設定を変更する権限を Flow に付与してください',
    },
    'mono_unsupported_toast': {
      'en': 'Mono Audio is not supported on this device',
      'id': 'Audio Mono tidak didukung di perangkat ini',
      'ja': 'モノラルオーディオはこのデバイスではサポートされていません',
    },

    // Silence Trimmer Toast
    'silence_enabled_toast': {
      'en': 'Silence trimmer enabled — truly silent sections will be skipped',
      'id':
          'Pemotong senyap aktif — bagian yang benar-benar senyap akan dilewati',
      'ja': 'サイレンストリマーが有効になりました — 完全に無音のセクションはスキップされます',
    },
    'silence_disabled_toast': {
      'en': 'Silence trimmer disabled',
      'id': 'Pemotong senyap dinonaktifkan',
      'ja': 'サイレンストリマーが無効になりました',
    },

    'custom_theme_bg': {
      'en': 'Custom Theme Background',
      'id': 'Latar Belakang Tema Kustom',
      'ja': 'カスタムテーマの背景',
    },
    'stops_in_timer': {'en': 'Stops in', 'id': 'Berhenti dalam', 'ja': '停止まで'},
    'mono_audio_info': {
      'en':
          "Info: Flow doesn't need to be in 'Downloaded Apps'. Simply toggle the global 'Mono Audio' switch on this screen!",
      'id':
          "Info: Flow tidak perlu ada di 'Aplikasi yang Diunduh'. Cukup aktifkan sakelar global 'Audio Mono' di layar ini!",
      'ja':
          "情報：Flowは「ダウンロード済みアプリ」にある必要はありません。この画面のグローバル「モノラルオーディオ」スイッチを切り替えるだけです！",
    },
    'mono_audio_permission': {
      'en':
          'Please grant Flow permission to modify system settings to toggle Mono Audio',
      'id':
          'Berikan izin kepada Flow untuk mengubah pengaturan sistem guna mengaktifkan Audio Mono',
      'ja': 'モノラルオーディオを切り替えるには、システム設定の変更権限をFlowに付与してください',
    },
    'mono_audio_not_supported': {
      'en': 'Mono Audio is not supported on this device',
      'id': 'Audio Mono tidak didukung di perangkat ini',
      'ja': 'モノラルオーディオはこのデバイスでサポートされていません',
    },

    'create_new_playlist': {
      'en': 'Create New Playlist',
      'id': 'Buat Playlist Baru',
      'ja': '新しいプレイリストを作成',
    },
    'my_playlists': {
      'en': 'My Playlists',
      'id': 'Playlist Saya',
      'ja': 'マイプレイリスト',
    },
    'no_matching_songs': {
      'en': 'No matching songs found',
      'id': 'Tidak ada lagu yang cocok',
      'ja': '該当する曲が見つかりません',
    },
    'plays_count': {'en': 'plays', 'id': 'putar', 'ja': '再生'},
    'songs_title': {'en': 'Songs', 'id': 'Lagu', 'ja': '曲'},
    'edit_playlist_title': {
      'en': 'Edit Playlist',
      'id': 'Edit Playlist',
      'ja': 'プレイリストを編集',
    },
    'add_songs': {'en': 'Add Songs', 'id': 'Tambah Lagu', 'ja': '曲を追加'},
    'deselect_all': {
      'en': 'Deselect All',
      'id': 'Batalkan Semua',
      'ja': '選択を解除',
    },
    'select_all': {'en': 'Select All', 'id': 'Pilih Semua', 'ja': 'すべて選択'},
    'remove_songs_confirm': {
      'en': 'Remove Songs?',
      'id': 'Hapus Lagu?',
      'ja': '曲を削除しますか？',
    },
    'remove_songs_body': {
      'en': 'Are you sure you want to remove selected songs?',
      'id': 'Apakah Anda yakin ingin menghapus lagu yang dipilih?',
      'ja': '選択した曲を削除してもよろしいですか？',
    },
    'remove': {'en': 'Remove', 'id': 'Hapus', 'ja': '削除'},
    'removed_songs_toast': {
      'en': 'Removed selected songs',
      'id': 'Berhasil menghapus lagu yang dipilih',
      'ja': '選択した曲を削除しました',
    },
    'no_songs_in_playlist': {
      'en': 'No songs in playlist',
      'id': 'Tidak ada lagu di playlist',
      'ja': 'プレイリストに曲がありません',
    },
    'playlist_name_placeholder': {
      'en': 'Playlist name',
      'id': 'Nama playlist',
      'ja': 'プレイリスト名',
    },
    'playlist_name_exists': {
      'en': 'Playlist name already exists',
      'id': 'Nama playlist sudah ada',
      'ja': 'プレイリスト名はすでに存在します',
    },
    'playlist_empty': {
      'en': 'Playlist is empty',
      'id': 'Playlist kosong',
      'ja': 'プレイリストが空です',
    },
    'added_songs_to_queue': {
      'en': 'Added songs to queue',
      'id': 'Berhasil menambahkan lagu ke antrian',
      'ja': '曲をキューに追加しました',
    },
    'edit_cover': {'en': 'Edit Cover', 'id': 'Edit Cover', 'ja': 'カバーを編集'},
    'playlist_cover_updated': {
      'en': 'Playlist cover updated',
      'id': 'Cover playlist diperbarui',
      'ja': 'プレイリストのカバーを更新しました',
    },
    'metadata_updated_local': {
      'en': 'Metadata updated locally',
      'id': 'Metadata diperbarui secara lokal',
      'ja': 'メタデータをローカルで更新しました',
    },
    'cover_updated_local': {
      'en': 'Album cover updated locally',
      'id': 'Cover album diperbarui secara lokal',
      'ja': 'アルバムカバーをローカルで更新しました',
    },
    'reset_confirm_body': {
      'en':
          'This will permanently delete your custom playlists, favorites, and play statistics.\n\nAudio files on your device will NOT be deleted.',
      'id':
          'Ini akan menghapus playlist kustom, favorit, dan statistik pemutaran secara permanen.\n\nFile audio di perangkat Anda TIDAK akan dihapus.',
      'ja':
          'これにより、カスタムプレイリスト、お気に入り、再生統計が完全に削除されます。\n\nデバイス上のオーディオファイルは削除されません。',
    },

    'create': {'en': 'Create', 'id': 'Buat', 'ja': '作成'},
    'playlist_created_format': {
      'en': "Playlist '{}' created",
      'id': "Playlist '{}' dibuat",
      'ja': "プレイリスト '{}' を作成しました",
    },
    'playlist_renamed': {
      'en': 'Playlist renamed',
      'id': 'Playlist berhasil diubah namanya',
      'ja': 'プレイリストの名前を変更しました',
    },
    'reset_settings_confirm_title': {
      'en': 'Reset Settings?',
      'id': 'Reset Pengaturan?',
      'ja': '設定をリセットしますか？',
    },

    'go_to_album': {'en': 'Go to Album', 'id': 'Buka Album', 'ja': 'アルバムへ移動'},
    'go_to_artist': {
      'en': 'Go to Artist',
      'id': 'Buka Artis',
      'ja': 'アーティストへ移動',
    },
    'song_info': {'en': 'Song Info', 'id': 'Informasi Lagu', 'ja': '曲の情報'},
    'hide_from_library': {
      'en': 'Hide from Library',
      'id': 'Sembunyikan dari Perpustakaan',
      'ja': 'ライブラリから非表示',
    },
    'delete_from_device': {
      'en': 'Delete from Device',
      'id': 'Hapus dari Perangkat',
      'ja': 'デバイスから削除',
    },
    'track_deleted': {
      'en': 'Track deleted',
      'id': 'Lagu dihapus',
      'ja': '曲を削除しました',
    },
    'file_not_found': {
      'en': 'File not found',
      'id': 'File tidak ditemukan',
      'ja': 'ファイルが見つかりません',
    },
    'permission_denied': {
      'en': 'Permission Denied',
      'id': 'Izin Ditolak',
      'ja': '権限が拒否されました',
    },
    'scoped_storage_warning': {
      'en':
          'Android Scoped Storage prevents Flow from directly deleting files in your device storage.\n\nWould you like to hide this track from your Flow library instead?',
      'id':
          'Android Scoped Storage mencegah Flow menghapus file secara langsung di penyimpanan perangkat.\n\nApakah Anda ingin menyembunyikan lagu ini dari perpustakaan Flow?',
      'ja':
          'Android Scoped Storageにより、Flowはデバイスストレージ内のファイルを直接削除できません。\n\n代わりに、この曲をFlowライブラリから非表示にしますか？',
    },
    'added_play_next': {
      'en': 'Added songs to play next',
      'id': 'Berhasil menambahkan lagu untuk diputar berikutnya',
      'ja': '曲を次に再生に追加しました',
    },
    'file_name': {'en': 'File Name', 'id': 'Nama File', 'ja': 'ファイル名'},
    'format': {'en': 'Format', 'id': 'Format', 'ja': 'フォーマット'},
    'size': {'en': 'Size', 'id': 'Ukuran', 'ja': 'サイズ'},
    'loading': {'en': 'Loading...', 'id': 'Memuat...', 'ja': '読み込み中...'},
    'file_path': {'en': 'File Path', 'id': 'Path File', 'ja': 'ファイルパス'},
    'select_image_source': {
      'en': 'Select Image Source',
      'id': 'Pilih Sumber Gambar',
      'ja': '画像ソースを選択',
    },
    'choose_from_gallery': {
      'en': 'Choose from Gallery',
      'id': 'Pilih dari Galeri',
      'ja': 'ギャラリーから選択',
    },
    'choose_from_song': {
      'en': 'Choose from Another Song',
      'id': 'Pilih dari Lagu Lain',
      'ja': '他の曲から選択',
    },
    'remove_custom_cover': {
      'en': 'Remove Custom Cover',
      'id': 'Hapus Cover Kustom',
      'ja': 'カスタムカバーを削除',
    },
    'cover_reset_success': {
      'en': 'Cover reset to default',
      'id': 'Cover dikembalikan ke bawaan',
      'ja': 'カバーをデフォルトにリセットしました',
    },
    'confirm_delete': {
      'en': 'Confirm Deletion',
      'id': 'Konfirmasi Penghapusan',
      'ja': '削除の確認',
    },
    'confirm_delete_body': {
      'en':
          'Are you sure you want to delete this track from your device? This action cannot be undone.',
      'id':
          'Yakin ingin menghapus lagu ini dari perangkat? Tindakan ini tidak dapat dibatalkan.',
      'ja': 'この曲をデバイスから削除してもよろしいですか？この操作は元に戻せません。',
    },
    'confirm_delete_playlist': {
      'en': 'Are you sure you want to delete this playlist?',
      'id': 'Yakin ingin menghapus playlist ini?',
      'ja': 'このプレイリストを削除してもよろしいですか？',
    },
    'confirm_backup': {
      'en': 'Confirm Backup',
      'id': 'Konfirmasi Cadangan',
      'ja': 'バックアップの確認',
    },
    'confirm_backup_body': {
      'en': 'Are you sure you want to backup your app data to Downloads?',
      'id': 'Yakin ingin mencadangkan data aplikasi ke folder Downloads?',
      'ja': 'アプリデータをダウンロードフォルダにバックアップしてもよろしいですか？',
    },
    'confirm_restore': {
      'en': 'Confirm Restore',
      'id': 'Konfirmasi Pemulihan',
      'ja': '復元の確認',
    },
    'confirm_restore_body': {
      'en':
          'Are you sure you want to restore app data? Your current settings and custom playlists will be overwritten.',
      'id':
          'Yakin ingin memulihkan data aplikasi? Pengaturan dan playlist kustom Anda saat ini akan ditimpa.',
      'ja': 'アプリデータを復元してもよろしいですか？現在の設定とカスタムプレイリストは上書きされます。',
    },
    'backup': {'en': 'Backup', 'id': 'Cadangkan', 'ja': 'バックアップ'},
    'restore': {'en': 'Restore', 'id': 'Pulihkan', 'ja': '復元'},

    // Sleep Timer Modal
    'sleep_timer_title': {
      'en': 'Sleep timer',
      'id': 'Timer tidur',
      'ja': 'スリープタイマー',
    },
    'end_of_track_short': {
      'en': 'End of track',
      'id': 'Akhir lagu',
      'ja': '曲の終了時',
    },
    'turn_off': {'en': 'Turn off', 'id': 'Matikan', 'ja': 'オフにする'},

    // Hidden Tracks Modal
    'hidden_tracks_desc': {
      'en':
          'Manage tracks that are manually hidden or automatically filtered out by your settings.',
      'id':
          'Kelola lagu yang disembunyikan secara manual atau otomatis difilter oleh pengaturan Anda.',
      'ja': '手動で非表示にした、または設定によって自動的にフィルタリングされた曲を管理します。',
    },
    'no_hidden_tracks': {
      'en': 'No hidden tracks found',
      'id': 'Tidak ada lagu tersembunyi',
      'ja': '非表示の曲は見つかりません',
    },
    'unknown_artist': {
      'en': 'Unknown Artist',
      'id': 'Artis Tidak Dikenal',
      'ja': '不明なアーティスト',
    },
    'unhide_track': {
      'en': 'Unhide track',
      'id': 'Tampilkan kembali',
      'ja': '曲を再表示',
    },

    // Most Played Threshold
    'most_played_threshold_title': {
      'en': 'Most Played Threshold',
      'id': 'Ambang Paling Sering Diputar',
      'ja': 'よく再生する曲のしきい値',
    },

    // Accent Descriptions
    'accent_desc_dynamic': {
      'en': 'Extract color dynamically from track art',
      'id': 'Ekstrak warna secara dinamis dari artwork lagu',
      'ja': 'トラックのアートワークから動的に色を抽出します',
    },
    'accent_desc_spotify': {
      'en': 'Classic energizing stream aesthetic',
      'id': 'Estetika streaming klasik yang energik',
      'ja': 'クラシックでエネルギッシュなストリーミングの美学',
    },
    'accent_desc_apple': {
      'en': 'Premium vibrant music vibe',
      'id': 'Getaran musik premium yang cerah',
      'ja': 'プレミアムで鮮やかな音楽の雰囲気',
    },
    'accent_desc_purple': {
      'en': 'Trendy dreamlike artistic look',
      'id': 'Tampilan artistik trendi bak mimpi',
      'ja': 'トレンディで夢のようなアーティスティックな外観',
    },
    'accent_desc_tidal': {
      'en': 'Clean hi-fi premium audio look',
      'id': 'Tampilan audio premium hi-fi yang bersih',
      'ja': 'クリーンなHi-Fiプレミアムオーディオの外観',
    },
    'accent_desc_orange': {
      'en': 'Warm cozy analog/vinyl feel',
      'id': 'Nuansa analog/vinyl yang hangat dan nyaman',
      'ja': '暖かく居心地の良いアナログ/ビニールの雰囲気',
    },
    'accent_desc_sakura': {
      'en': 'Futuristic sleek cyberpunk vibe',
      'id': 'Getaran cyberpunk futuristik yang sleek',
      'ja': '未来的でスリークなサイバーパンクの雰囲気',
    },
    'accent_desc_gold': {
      'en': 'Polished warm golden studio feel',
      'id': 'Nuansa studio emas yang hangat dan halus',
      'ja': '洗練された暖かいゴールデンスタジオの雰囲気',
    },
    'accent_desc_blue': {
      'en': 'Premium deep ocean audio look',
      'id': 'Tampilan audio lautan dalam yang premium',
      'ja': 'プレミアムなディープオーシャンオーディオの外観',
    },
    'accent_desc_lime': {
      'en': 'Bold neon party energy',
      'id': 'Energi pesta neon yang berani',
      'ja': '大胆なネオンパーティーのエネルギー',
    },

    // Accent Dialog Header
    'accent_dialog_subtitle': {
      'en': 'Personalize the system accent color & player highlights',
      'id': 'Personalisasi warna aksen sistem & sorotan pemutar',
      'ja': 'システムのアクセントカラーとプレーヤーのハイライトをカスタマイズ',
    },

    // Player Background Descriptions
    'player_bg_desc_gradient': {
      'en': 'Extract color and paint a rich dark linear gradient',
      'id': 'Ekstrak warna dan gambar gradien linear gelap yang kaya',
      'ja': '色を抽出してリッチなダークリニアグラデーションを描きます',
    },
    'player_bg_desc_blur': {
      'en': 'Full-screen blurred album art with glassmorphism overlay',
      'id': 'Artwork album blur layar penuh dengan overlay glassmorphism',
      'ja': 'フルスクリーンのぼかしアルバムアートとグラスモーフィズムオーバーレイ',
    },
    'player_bg_desc_amoled': {
      'en': 'Solid pure black background for ultimate battery saving',
      'id': 'Latar hitam pekat solid untuk hemat baterai maksimal',
      'ja': '究極のバッテリー節約のためのソリッドなピュアブラック背景',
    },
    'player_bg_desc_custom': {
      'en': 'Set a personalized wallpaper background from your photo gallery',
      'id': 'Atur wallpaper personal dari galeri foto Anda',
      'ja': 'フォトギャラリーからパーソナライズされた壁紙背景を設定',
    },

    // Player Background Dialog Header
    'player_bg_dialog_subtitle': {
      'en': 'Choose your Now Playing visual experience',
      'id': 'Pilih tampilan visual Now Playing Anda',
      'ja': 'Now Playingのビジュアル体験を選択',
    },

    // Theme Mode Descriptions
    'theme_mode_desc_dark': {
      'en': 'Sleek battery-saving dark interface',
      'id': 'Antarmuka gelap yang sleek dan hemat baterai',
      'ja': 'スリークでバッテリー節約のダークインターフェース',
    },
    'theme_mode_desc_light': {
      'en': 'Clean bright aesthetic for daytime use',
      'id': 'Estetika terang dan bersih untuk penggunaan siang hari',
      'ja': '日中使用のためのクリーンで明るい美学',
    },
    'theme_mode_desc_custom': {
      'en': 'Unlock premium luxury backgrounds & colors',
      'id': 'Buka latar belakang & warna mewah premium',
      'ja': 'プレミアムなラグジュアリー背景＆カラーをアンロック',
    },

    // Theme Mode Dialog Header
    'theme_mode_dialog_subtitle': {
      'en': 'Personalize the look and feel of your app',
      'id': 'Personalisasi tampilan dan nuansa aplikasi Anda',
      'ja': 'アプリの外観とフィールをカスタマイズ',
    },

    // Theme Bg Option Names (For Inline Chips)
    'bg_custom_image': {
      'en': 'Custom Image',
      'id': 'Gambar Kustom',
      'ja': 'カスタム画像',
    },
    'bg_deep_navy': {'en': 'Deep Navy', 'id': 'Biru Tua', 'ja': 'ディープネイビー'},
    'bg_forest_green': {
      'en': 'Forest Green',
      'id': 'Hijau Hutan',
      'ja': 'フォレストグリーン',
    },
    'bg_midnight_wine': {
      'en': 'Midnight Wine',
      'id': 'Anggur Malam',
      'ja': 'ミッドナイトワイン',
    },
    'bg_sunset_terracotta': {
      'en': 'Sunset Terracotta',
      'id': 'Terakota Senja',
      'ja': 'サンセットテラコッタ',
    },
    'bg_slate_gray_blue': {
      'en': 'Slate Gray-Blue',
      'id': 'Abu Biru Batu',
      'ja': 'スレートグレーブルー',
    },

    // Update Dialog
    'current_version': {
      'en': 'Current Version',
      'id': 'Versi Saat Ini',
      'ja': '現在のバージョン',
    },
    'latest_version': {
      'en': 'Latest Version',
      'id': 'Versi Terbaru',
      'ja': '最新バージョン',
    },
    'could_not_open_update': {
      'en': 'Could not open update page',
      'id': 'Tidak bisa membuka halaman update',
      'ja': 'アップデートページを開けませんでした',
    },

    // Wallpaper Toasts
    'custom_theme_wallpaper_updated': {
      'en': 'Custom theme wallpaper updated!',
      'id': 'Wallpaper tema kustom diperbarui!',
      'ja': 'カスタムテーマ壁紙が更新されました！',
    },

    // Next (For Playlist Queue)
    'next': {'en': 'Next', 'id': 'Selanjutnya', 'ja': '次へ'},

    // Hidden Track Badges
    'badge_hidden': {'en': 'HIDDEN', 'id': 'TERSEMBUNYI', 'ja': '非表示'},
    'badge_short_audio': {
      'en': 'SHORT AUDIO',
      'id': 'AUDIO PENDEK',
      'ja': '短い音声',
    },

    // Timer Options
    'minutes_format': {'en': 'minutes', 'id': 'menit', 'ja': '分'},
    'hour_1': {'en': '1 hour', 'id': '1 jam', 'ja': '1 時間'},
    'minute_1': {'en': '1 minute', 'id': '1 menit', 'ja': '1 分'},
    'seconds_format': {'en': 'seconds', 'id': 'detik', 'ja': '秒'},
    'seconds_default_format': {
      'en': 'seconds (Default)',
      'id': 'detik (Default)',
      'ja': '秒（デフォルト）',
    },
    // Specific Folder Scan
    'folder_scan_desc': {
      'en':
          'Select which folders to display in your library. Unselected folders will be hidden.',
      'id':
          'Pilih folder mana yang akan ditampilkan di perpustakaan Anda. Folder yang tidak dipilih akan disembunyikan.',
      'ja': 'ライブラリに表示するフォルダを選択します。選択されていないフォルダは非表示になります。',
    },
    'reset_filter': {
      'en': 'Reset Filter',
      'id': 'Setel Ulang Filter',
      'ja': 'フィルターをリセット',
    },
    'no_music_folders': {
      'en': 'No music folders found',
      'id': 'Tidak ada folder musik ditemukan',
      'ja': '音楽フォルダが見つかりません',
    },
    'folder_root': {'en': 'Root', 'id': 'Akar', 'ja': 'ルート'},

    // Hidden Tracks Extras
    'hidden_filtered_tracks_title': {
      'en': 'Hidden & Filtered Tracks',
      'id': 'Lagu Tersembunyi & Difilter',
      'ja': '非表示およびフィルタリングされた曲',
    },
    'tracks_count_suffix': {'en': ' tracks', 'id': ' lagu', 'ja': '曲'},
    'auto_hidden_tooltip': {
      'en': 'Auto-hidden by Short Audio filter',
      'id': 'Sembunyikan otomatis oleh filter Audio Pendek',
      'ja': '短いオーディオフィルターにより自動非表示',
    },
    'auto_hidden_toast': {
      'en':
          'This track is automatically hidden because it is shorter than 30s.',
      'id':
          'Lagu ini disembunyikan otomatis karena durasinya kurang dari 30 detik.',
      'ja': 'この曲は30秒未満のため、自動的に非表示になります。',
    },
    // Equalizer Modal
    'system_equalizer': {
      'en': 'System Equalizer',
      'id': 'Ekualiser Sistem',
      'ja': 'システムイコライザー',
    },

    'eq_error_play_first': {
      'en': 'Play a song first to initialize the Equalizer!',
      'id': 'Putar lagu terlebih dahulu untuk menginisialisasi Ekualiser!',
      'ja': 'イコライザーを初期化するには、まず曲を再生してください！',
    },
    'eq_error_unsupported': {
      'en': 'Equalizer is not supported on this device',
      'id': 'Ekualiser tidak didukung di perangkat ini',
      'ja': 'このデバイスではイコライザーはサポートされていません',
    },
    // Sorting And Details
    'sort_recently_added': {
      'en': 'Recently Added (Default)',
      'id': 'Baru Ditambahkan (Default)',
      'ja': '最近追加（デフォルト）',
    },
    'sort_oldest': {
      'en': 'Oldest Added first',
      'id': 'Paling Lama Ditambahkan',
      'ja': '追加の古い順',
    },
    'sort_title_az': {
      'en': 'Title (A to Z)',
      'id': 'Judul (A-Z)',
      'ja': 'タイトル（AからZ）',
    },
    'sort_artist_az': {
      'en': 'Artist (A to Z)',
      'id': 'Artis (A-Z)',
      'ja': 'アーティスト（AからZ）',
    },
    'sort_album_az': {
      'en': 'Album (A to Z)',
      'id': 'Album (A-Z)',
      'ja': 'アルバム（AからZ）',
    },
    'sort_duration_longest': {
      'en': 'Duration (Longest first)',
      'id': 'Durasi (Paling Lama)',
      'ja': '再生時間（長い順）',
    },
    'sort_duration_shortest': {
      'en': 'Duration (Shortest first)',
      'id': 'Durasi (Paling Sebentar)',
      'ja': '再生時間（短い順）',
    },
    'sort_songs_in_view': {
      'en': 'Sort songs in view',
      'id': 'Urutkan lagu dalam tampilan',
      'ja': '表示中の曲を並べ替える',
    },
    'sort_default_order': {
      'en': 'Default Track Order',
      'id': 'Urutan Lagu Default',
      'ja': 'デフォルトの曲順',
    },
    'unknown_literal': {'en': 'Unknown', 'id': 'Tidak diketahui', 'ja': '不明'},
    // Toast Messages
    'toast_headphones_unplugged': {
      'en': 'Headphones unplugged. Paused.',
      'id': 'Headphone dicabut. Dijeda.',
      'ja': 'ヘッドフォンが取り外されました。一時停止しました。',
    },
    'toast_app_data_reset': {
      'en': 'App data has been reset.',
      'id': 'Data aplikasi telah di-reset.',
      'ja': 'アプリデータがリセットされました。',
    },
    'toast_bg_style_set': {
      'en': 'Background style set to',
      'id': 'Gaya latar belakang diatur ke',
      'ja': '背景スタイルを次に設定：',
    },
    'toast_theme_style_set': {
      'en': 'Theme style set to',
      'id': 'Gaya tema diatur ke',
      'ja': 'テーマスタイルを次に設定：',
    },
    'toast_removed_recently_played': {
      'en': 'Removed from Recently Played!',
      'id': 'Dihapus dari Baru Diputar!',
      'ja': '最近再生した曲から削除しました！',
    },
    'toast_excluded_most_played': {
      'en': 'Excluded from Most Played!',
      'id': 'Dikecualikan dari Paling Sering Diputar!',
      'ja': 'よく再生する曲から除外しました！',
    },
    'toast_scan_triggered': {
      'en': 'Audio Library scan triggered...',
      'id': 'Pemindaian Perpustakaan Audio dimulai...',
      'ja': 'オーディオライブラリスキャンが開始されました...',
    },
    'toast_scan_completed': {
      'en': 'Scan completed!',
      'id': 'Pemindaian selesai!',
      'ja': 'スキャンが完了しました！',
    },
    'toast_scanning_folders': {
      'en': 'Scanning folders...',
      'id': 'Memindai folder...',
      'ja': 'フォルダをスキャン中...',
    },
    'toast_folder_scan_completed': {
      'en': 'Folder scan completed!',
      'id': 'Pemindaian folder selesai!',
      'ja': 'フォルダスキャンが完了しました！',
    },
    'toast_selected_folders_updated': {
      'en': 'Selected folders updated and scan completed!',
      'id': 'Folder terpilih diperbarui dan pemindaian selesai!',
      'ja': '選択したフォルダが更新され、スキャンが完了しました！',
    },
    'toast_lyrics_updated': {
      'en': 'Lyrics updated!',
      'id': 'Lirik diperbarui!',
      'ja': '歌詞が更新されました！',
    },
    'toast_removed_playlist': {
      'en': 'Removed from playlist:',
      'id': 'Dihapus dari playlist:',
      'ja': 'プレイリストから削除しました：',
    },
    'toast_added_to': {
      'en': 'Added to',
      'id': 'Ditambahkan ke',
      'ja': 'に追加しました：',
    },
    'toast_one_added_skipped': {
      'en': '1 song added, {} skipped (already in playlist).',
      'id': '1 lagu ditambahkan, {} dilewati (sudah ada di playlist).',
      'ja': '1曲追加、{}曲スキップ（プレイリストに既に存在）。',
    },
    'toast_many_added_skipped': {
      'en': '{} songs added, {} skipped (already in playlist).',
      'id': '{} lagu ditambahkan, {} dilewati (sudah ada di playlist).',
      'ja': '{}曲追加、{}曲スキップ（プレイリストに既に存在）。',
    },
    'toast_added_songs_to': {
      'en': 'Added {} songs to {}!',
      'id': 'Menambahkan {} lagu ke {}!',
      'ja': '{}曲を{}に追加しました！',
    },
    'toast_all_songs_already_in_playlist': {
      'en': 'All songs are already in the playlist.',
      'id': 'Semua lagu sudah ada di playlist.',
      'ja': 'すべての曲はすでにプレイリストにあります。',
    },
    'toast_song_already_in_playlist': {
      'en': '\'{}\' is already in {}',
      'id': '\'{}\' sudah ada di {}',
      'ja': '\'{}\'はすでに{}にあります',
    },
    'toast_added_song_to': {
      'en': 'Added \'{}\' to {}',
      'id': 'Menambahkan \'{}\' ke {}',
      'ja': '\'{}\'を{}に追加しました',
    },
    'toast_selected_songs_already_in': {
      'en': 'Selected songs are already in {}',
      'id': 'Lagu terpilih sudah ada di {}',
      'ja': '選択した曲はすでに{}にあります',
    },
    'toast_added_songs_skipped': {
      'en': 'Added {} songs to {} ({} skipped)',
      'id': 'Menambahkan {} lagu ke {} ({} dilewati)',
      'ja': '{}曲を{}に追加しました（{}曲スキップ）',
    },
    'toast_added_songs_to_simple': {
      'en': 'Added {} songs to {}',
      'id': 'Menambahkan {} lagu ke {}',
      'ja': '{}曲を{}に追加しました',
    },
  };
}

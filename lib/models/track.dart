class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String url;
  final String path;
  final List<String> lyrics;
  final int duration;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.url,
    required this.path,
    required this.lyrics,
    required this.duration,
  });
}

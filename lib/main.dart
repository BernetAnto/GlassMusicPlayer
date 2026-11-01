import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const GlassMusicApp());
}

class GlassMusicApp extends StatelessWidget {
  const GlassMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MusicHome(),
    );
  }
}

class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String artwork;

  MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.artwork,
  });

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final art = json['artwork'];

    String image = '';

    if (art is Map) {
      image = art['150x150'] ??
          art['480x480'] ??
          art['1000x1000'] ??
          '';
    }

    return MusicTrack(
      id: json['id'].toString(),
      title: json['title'] ?? 'Unknown Song',
      artist: user['name'] ?? 'Unknown Artist',
      artwork: image,
    );
  }
}

class MusicHome extends StatefulWidget {
  const MusicHome({super.key});

  @override
  State<MusicHome> createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  final AudioPlayer player = AudioPlayer();
  final TextEditingController searchController =
      TextEditingController();

  List<MusicTrack> songs = [];

  bool loading = true;
  bool searching = false;

  MusicTrack? currentTrack;

  final String baseUrl =
      'https://discoveryprovider.audius.co/v1';

  @override
  void initState() {
    super.initState();
    loadTrending();
  }

  Future<void> loadTrending() async {
    setState(() {
      loading = true;
      searching = false;
    });

    try {
      final url = Uri.parse(
        '$baseUrl/tracks/trending?limit=30',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final List data = result['data'] ?? [];

        setState(() {
          songs = data
              .map((e) => MusicTrack.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      showMessage('Unable to load songs. Check internet.');
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> searchSongs(String query) async {
    if (query.trim().isEmpty) {
      loadTrending();
      return;
    }

    setState(() {
      loading = true;
      searching = true;
    });

    try {
      final url = Uri.parse(
        '$baseUrl/tracks/search',
      ).replace(queryParameters: {
        'query': query,
        'limit': '30',
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final List data = result['data'] ?? [];

        setState(() {
          songs = data
              .map((e) => MusicTrack.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      showMessage('Search failed. Try again.');
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> playSong(MusicTrack song) async {
    try {
      setState(() {
        currentTrack = song;
      });

      final streamUrl =
          '$baseUrl/tracks/${song.id}/stream';

      await player.setUrl(streamUrl);
      await player.play();
    } catch (e) {
      showMessage('This song cannot be played.');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    player.dispose();
    searchController.dispose();
    super.dispose();
  }

  Widget songArtwork(MusicTrack song, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: song.artwork.isNotEmpty
          ? Image.network(
              song.artwork,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  artworkPlaceholder(size),
            )
          : artworkPlaceholder(size),
    );
  }

  Widget artworkPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.deepPurple.shade900,
      child: const Icon(
        Icons.music_note,
        color: Colors.white,
        size: 35,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080812),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF21113D),
              Color(0xFF080812),
              Color(0xFF101020),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GLASS MUSIC',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Your music universe',
                      style: TextStyle(
                        color: Colors.white60,
                      ),
                    ),

                    const SizedBox(height: 22),

                    TextField(
                      controller: searchController,
                      onSubmitted: searchSongs,
                      decoration: InputDecoration(
                        hintText: 'Search songs or artists',
                        prefixIcon:
                            const Icon(Icons.search),
                        filled: true,
                        fillColor:
                            Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          searching
                              ? 'Search Results'
                              : 'Trending Music',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          onPressed: loadTrending,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : songs.isEmpty
                        ? const Center(
                            child: Text('No songs found'),
                          )
                        : RefreshIndicator(
                            onRefresh: loadTrending,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(
                                bottom: 15,
                              ),
                              itemCount: songs.length,
                              itemBuilder: (context, index) {
                                final song = songs[index];

                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                  leading: songArtwork(
                                    song,
                                    55,
                                  ),
                                  title: Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    song.artist,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.purpleAccent,
                                      size: 32,
                                    ),
                                    onPressed: () =>
                                        playSong(song),
                                  ),
                                  onTap: () =>
                                      playSong(song),
                                );
                              },
                            ),
                          ),
              ),

              if (currentTrack != null)
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          songArtwork(currentTrack!, 48),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentTrack!.title,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  currentTrack!.artist,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          StreamBuilder<PlayerState>(
                            stream: player.playerStateStream,
                            builder: (context, snapshot) {
                              final state = snapshot.data;
                              final playing =
                                  state?.playing ?? false;

                              final buffering =
                                  state?.processingState ==
                                      ProcessingState.loading ||
                                  state?.processingState ==
                                      ProcessingState.buffering;

                              if (buffering) {
                                return const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              }

                              return IconButton(
                                icon: Icon(
                                  playing
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                  size: 35,
                                  color: Colors.purpleAccent,
                                ),
                                onPressed: () {
                                  if (playing) {
                                    player.pause();
                                  } else {
                                    player.play();
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),

                      StreamBuilder<Duration?>(
                        stream: player.durationStream,
                        builder: (context, snapshot) {
                          final duration =
                              snapshot.data ?? Duration.zero;

                          return StreamBuilder<Duration>(
                            stream: player.positionStream,
                            builder: (context, positionSnapshot) {
                              final position =
                                  positionSnapshot.data ??
                                      Duration.zero;

                              final max =
                                  duration.inMilliseconds
                                      .toDouble();

                              final value = max > 0
                                  ? position.inMilliseconds
                                      .toDouble()
                                      .clamp(0.0, max)
                                  : 0.0;

                              return Slider(
                                value: value,
                                max: max > 0 ? max : 1,
                                onChanged: (v) {
                                  player.seek(
                                    Duration(
                                      milliseconds: v.toInt(),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(const GlassMusicApp());

class GlassMusicApp extends StatelessWidget {
  const GlassMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glass Music',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090B16),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFB7A4FF),
          secondary: Color(0xFF75E4D2),
        ),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
    );
  }
}

class Track {
  final String title;
  final String artist;
  final String tag;
  final List<Color> colors;

  const Track(this.title, this.artist, this.tag, this.colors);
}

const tracks = [
  Track('Hukum', 'Anirudh Ravichander', 'TAMIL • TRENDING',
      [Color(0xFF6D3B9B), Color(0xFFDC658B)]),
  Track('Ordinary', 'Alex Warren', 'ENGLISH • POP',
      [Color(0xFF245C75), Color(0xFF70B8C8)]),
  Track('Katchi Sera', 'Sai Abhyankkar', 'TAMIL • VIBE',
      [Color(0xFFB45C3D), Color(0xFFE6B56A)]),
  Track('Beautiful Things', 'Benson Boone', 'ENGLISH • HITS',
      [Color(0xFF455B9A), Color(0xFF9D78C9)]),
];

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  int selectedTab = 0;
  int selectedTrack = 0;
  bool isPlaying = false;
  bool showLyrics = false;

  @override
  Widget build(BuildContext context) {
    final track = tracks[selectedTrack];
    return Scaffold(
      body: Stack(
        children: [
          const _AmbientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(),
                  const SizedBox(height: 28),
                  Text(
                    selectedTab == 0 ? 'Feel the music.' : _tabTitle(),
                    style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedTab == 0
                        ? 'Your sound, your space.'
                        : 'Your music collection, beautifully arranged.',
                    style: TextStyle(color: Colors.white.withOpacity(.58)),
                  ),
                  const SizedBox(height: 22),
                  if (selectedTab == 0) ...[
                    _sectionTitle('FEATURED MIX', 'MADE FOR YOU'),
                    const SizedBox(height: 12),
                    _featuredCard(track),
                    const SizedBox(height: 24),
                    _sectionTitle('TRENDING NOW', 'SEE ALL'),
                    const SizedBox(height: 10),
                    Expanded(child: _trackList()),
                  ] else ...[
                    Expanded(child: _libraryContent()),
                  ],
                  if (showLyrics) _lyricsPanel(track),
                  _miniPlayer(track),
                  const SizedBox(height: 12),
                  _bottomNavigation(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _tabTitle() => ['Home', 'Search', 'Library', 'Lyrics'][selectedTab];

  Widget _topBar() => Row(
        children: [
          Container(
            height: 42, width: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFFB7A4FF), Color(0xFF75E4D2)],
              ),
            ),
            child: const Icon(Icons.graphic_eq_rounded,
                color: Color(0xFF111322), size: 26),
          ),
          const SizedBox(width: 11),
          const Text('GLASS',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
                  letterSpacing: 2.4)),
          const Spacer(),
          _circleButton(Icons.search_rounded, () {
            setState(() => selectedTab = 1);
          }),
          const SizedBox(width: 10),
          _circleButton(Icons.tune_rounded, () => _showSettings()),
        ],
      );

  Widget _circleButton(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: GlassCard(
          radius: 30,
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20),
        ),
      );

  Widget _sectionTitle(String title, String action) => Row(
        children: [
          Text(title, style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const Spacer(),
          Text(action, style: TextStyle(
              fontSize: 10, color: Colors.white.withOpacity(.48),
              letterSpacing: 1.2, fontWeight: FontWeight.w700)),
        ],
      );

  Widget _featuredCard(Track track) => GlassCard(
        radius: 25,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _artwork(track, 112),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.tag, style: const TextStyle(
                      color: Color(0xFFB7A4FF), fontSize: 9,
                      fontWeight: FontWeight.w800, letterSpacing: 1.3)),
                  const SizedBox(height: 8),
                  Text(track.title, style: const TextStyle(
                      fontSize: 21, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(track.artist, style: TextStyle(
                      fontSize: 12, color: Colors.white.withOpacity(.6))),
                  const SizedBox(height: 12),
                  Row(children: [
                    _playButton(() => setState(() => isPlaying = !isPlaying)),
                    const SizedBox(width: 9),
                    Text(isPlaying ? 'PLAYING' : 'PLAY PREVIEW',
                        style: const TextStyle(fontSize: 9,
                            fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _trackList() => ListView.separated(
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: tracks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = tracks[index];
          return InkWell(
            onTap: () => setState(() {
              selectedTrack = index;
              isPlaying = true;
            }),
            borderRadius: BorderRadius.circular(17),
            child: GlassCard(
              radius: 17,
              padding: const EdgeInsets.all(9),
              child: Row(children: [
                _artwork(item, 48),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(item.artist, style: TextStyle(
                        fontSize: 10, color: Colors.white.withOpacity(.55))),
                  ],
                )),
                Icon(
                  selectedTrack == index && isPlaying
                      ? Icons.equalizer_rounded : Icons.more_horiz_rounded,
                  color: const Color(0xFFB7A4FF),
                ),
              ]),
            ),
          );
        },
      );

  Widget _libraryContent() {
    if (selectedTab == 1) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GlassCard(
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: const TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.search_rounded),
              hintText: 'Search songs, artists, albums...',
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Explore music', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _categoryTile('Tamil Trending', 'Kollywood • Latest hits',
            const Color(0xFF8D4D9F), Icons.music_note_rounded),
        _categoryTile('English Hits', 'Pop • Global charts',
            const Color(0xFF326D82), Icons.language_rounded),
      ]);
    }
    if (selectedTab == 3) {
      return Center(child: TextButton.icon(
        onPressed: () => setState(() => showLyrics = !showLyrics),
        icon: const Icon(Icons.lyrics_rounded),
        label: const Text('Open current song lyrics'),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Your library', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      _categoryTile('All Songs', 'Songs on your device',
          const Color(0xFF655B9A), Icons.library_music_rounded),
      _categoryTile('Playlists', 'Your personal collections',
          const Color(0xFF3D8B83), Icons.queue_music_rounded),
      _categoryTile('Favorites', 'Songs you love',
          const Color(0xFF9C536F), Icons.favorite_rounded),
      const SizedBox(height: 12),
      Text('Device music scanning will be connected in the next build.',
          style: TextStyle(color: Colors.white.withOpacity(.5), fontSize: 12)),
    ]);
  }

  Widget _categoryTile(String title, String subtitle, Color color, IconData icon) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassCard(
          radius: 17,
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              height: 42, width: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(.3),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(
                    fontSize: 11, color: Colors.white.withOpacity(.55))),
              ],
            )),
            const Icon(Icons.chevron_right_rounded),
          ]),
        ),
      );

  Widget _lyricsPanel(Track track) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassCard(
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(children: [
              const Text('LYRICS', style: TextStyle(
                  fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => showLyrics = false),
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ]),
            Text(track.title, style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Lyrics will appear here when an authorized lyrics source\\nor saved LRC file is connected.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5, color: Color(0xFFB7A4FF))),
          ]),
        ),
      );

  Widget _miniPlayer(Track track) => GlassCard(
        radius: 19,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        child: Row(children: [
          _artwork(track, 42),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(track.title, style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700)),
              Text(track.artist, style: TextStyle(
                  fontSize: 10, color: Colors.white.withOpacity(.55))),
            ],
          )),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => setState(() => showLyrics = !showLyrics),
            icon: const Icon(Icons.lyrics_rounded, color: Color(0xFFB7A4FF)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => setState(() => isPlaying = !isPlaying),
            icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 29),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => setState(() {
              selectedTrack = (selectedTrack + 1) % tracks.length;
              isPlaying = true;
            }),
            icon: const Icon(Icons.skip_next_rounded, size: 27),
          ),
        ]),
      );

  Widget _bottomNavigation() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'Home', 0),
          _navItem(Icons.search_rounded, 'Search', 1),
          _navItem(Icons.library_music_rounded, 'Library', 2),
          _navItem(Icons.lyrics_rounded, 'Lyrics', 3),
        ],
      );

  Widget _navItem(IconData icon, String label, int index) {
    final active = selectedTab == index;
    return InkWell(
      onTap: () => setState(() => selectedTab = index),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20,
              color: active ? const Color(0xFFB7A4FF) : Colors.white54),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 9,
              color: active ? const Color(0xFFB7A4FF) : Colors.white54)),
        ]),
      ),
    );
  }

  Widget _artwork(Track track, double size) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * .22),
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: track.colors,
          ),
        ),
        child: Icon(Icons.graphic_eq_rounded,
            size: size * .48, color: Colors.white.withOpacity(.85)),
      );

  Widget _playButton(VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 34, width: 34,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFB7A4FF), Color(0xFF75E4D2)],
            ),
          ),
          child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: const Color(0xFF111322)),
        ),
      );

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171A2B),
      builder: (_) => const Padding(
        padding: EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Audio permissions, offline library scanning and playback settings will be added in the next phase.'),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.075),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.white.withOpacity(.13)),
            ),
            child: child,
          ),
        ),
      );
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF17152D), Color(0xFF090B16), Color(0xFF101D27)],
            ),
          ),
          child: Stack(children: [
            Positioned(
              top: -90, right: -80,
              child: _glow(const Color(0xFF8D5CFF), 240),
            ),
            Positioned(
              bottom: 100, left: -110,
              child: _glow(const Color(0xFF287D88), 260),
            ),
          ]),
        ),
      );

  Widget _glow(Color color, double size) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(.27),
              blurRadius: 100, spreadRadius: 35)],
        ),
      );
}

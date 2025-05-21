import 'package:flutter/material.dart';
import 'login_page.dart';
import 'playlist_page.dart';
import 'playlist_song_detail.dart'; // Import halaman detail lagu

void main() {
  runApp(const SongPlaylistApp());
}

class SongPlaylistApp extends StatelessWidget {
  const SongPlaylistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Song App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/playlistDetail') {
          final args = settings.arguments as Map<String, dynamic>;
          final playlistId = args['playlistId'] as String;

          return MaterialPageRoute(
            builder: (context) => PlaylistSongDetailPage(playlistId: playlistId, song: null,),
          );
        }

        // Fallback untuk rute default
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
        );
      },
      routes: {
        '/': (context) => const LoginPage(),
        '/playlist': (context) => const PlaylistSongPage(),
      },
    );
  }
}

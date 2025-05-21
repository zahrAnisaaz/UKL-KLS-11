import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:song/playlist_song_detail.dart';
import 'dart:convert';

class PlaylistSongListPage extends StatefulWidget {
  final String playlistId;
  final String playlistName;

  const PlaylistSongListPage({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<PlaylistSongListPage> createState() => _PlaylistSongListPageState();
}

class _PlaylistSongListPageState extends State<PlaylistSongListPage> {
  List<dynamic> songs = [];
  Set<String> likedSongs = {}; // Untuk menyimpan ID lagu yang disukai
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    final url = Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl2/playlists/song-list/${widget.playlistId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          songs = jsonData['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load songs');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic> get filteredSongs {
    if (searchQuery.isEmpty) {
      return songs;
    } else {
      return songs.where((song) {
        final title = song['title'].toString().toLowerCase();
        final artist = song['artist'].toString().toLowerCase();
        final query = searchQuery.toLowerCase();
        return title.contains(query) || artist.contains(query);
      }).toList();
    }
  }

  void playSong(dynamic song) {
    // Placeholder: ganti dengan pemutar lagu sebenarnya
    print('Playing: ${song['title']} by ${song['artist']}');
  }

  void toggleLike(String songId) {
    setState(() {
      if (likedSongs.contains(songId)) {
        likedSongs.remove(songId);
      } else {
        likedSongs.add(songId);
      }
    });

    // TODO: Kirim ke backend jika ingin menyimpan like
    print(likedSongs.contains(songId)
        ? 'Liked song $songId'
        : 'Unliked song $songId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Pop Hits'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan judul atau artis...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = filteredSongs[index];
                      final songId = song['uuid'].toString();
                      final String thumbnailUrl = (song['thumbnail'] != null &&
                              song['thumbnail'].toString().isNotEmpty)
                          ? 'https://learn.smktelkom-mlg.sch.id/ukl2/thumbnail/${song['thumbnail']}'
                          : 'https://via.placeholder.com/300x180.png?text=No+Image';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaylistSongDetailPage(
                                song: song,
                                playlistId: widget.playlistId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  thumbnailUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(song['artist']),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.play_circle_fill,
                                    color: Colors.blueAccent, size: 30),
                                onPressed: () => playSong(song),
                              ),
                              IconButton(
                                icon: Icon(
                                  likedSongs.contains(songId)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: likedSongs.contains(songId)
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () => toggleLike(songId),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}





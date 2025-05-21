import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:song/AddSongPage.dart';
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'add_song_page.dart'; // Tambahkan import ini

class PlaylistSongDetailPage extends StatefulWidget {
  final String playlistId;

  const PlaylistSongDetailPage({super.key, required this.playlistId, required song});

  @override
  State<PlaylistSongDetailPage> createState() => _PlaylistSongDetailPageState();
}

class _PlaylistSongDetailPageState extends State<PlaylistSongDetailPage> {
  List<dynamic> songs = [];
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    final url = Uri.parse(
        'https://learn.smktelkom-mlg.sch.id/ukl2/playlists/song-list/${widget.playlistId}');
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

  Widget buildCommentCard(dynamic comment) {
    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(comment['comment_text']),
        subtitle: Text("by ${comment['creator']}"),
        leading: const Icon(Icons.comment, color: Colors.blueAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Playlist Songs'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title or artist',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: Colors.white,
                      filled: true,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = filteredSongs[index];
                      final String thumbnailUrl = (song['thumbnail'] != null &&
                              song['thumbnail'].toString().isNotEmpty)
                          ? 'https://learn.smktelkom-mlg.sch.id/ukl2/thumbnail/${song['thumbnail']}'
                          : 'https://via.placeholder.com/300x180.png?text=No+Image';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SongDetailPage(song: song),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  thumbnailUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.broken_image,
                                        size: 100, color: Colors.grey);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              song['title'],
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              song['artist'],
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(song['description']),
                            const SizedBox(height: 12),
                            Text("❤️ ${song['likes']} likes"),
                            const Divider(height: 30),
                            const Text(
                              "Comments",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            ...song['comments']
                                .map<Widget>(
                                    (comment) => buildCommentCard(comment))
                                .toList(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSongPage(playlistId: widget.playlistId),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

class SongDetailPage extends StatelessWidget {
  final Map<String, dynamic> song;

  const SongDetailPage({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final String videoId = YoutubePlayer.convertUrlToId(song['source'] ?? '') ?? '';
    final String thumbnailUrl = (song['thumbnail'] != null &&
            song['thumbnail'].toString().isNotEmpty)
        ? 'https://learn.smktelkom-mlg.sch.id/ukl2/thumbnail/${song['thumbnail']}'
        : 'https://via.placeholder.com/300x180.png?text=No+Image';

    return Scaffold(
      appBar: AppBar(
        title: Text(song['title']),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (videoId.isNotEmpty)
            YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: videoId,
                flags: const YoutubePlayerFlags(
                  autoPlay: false,
                  mute: false,
                ),
              ),
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.blueAccent,
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                thumbnailUrl,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(song['title'],
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(song['artist'],
              style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(song['description']),
          const SizedBox(height: 16),
          Text("❤️ ${song['likes']} likes"),
          const Divider(height: 32),
          const Text("Comments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...song['comments']
              .map<Widget>((c) => Card(
                    color: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(c['comment_text']),
                      subtitle: Text("by ${c['creator']}"),
                      leading: const Icon(Icons.comment, color: Colors.blueAccent),
                    ),
                  ))
              .toList()
        ],
      ),
    );
  }
}




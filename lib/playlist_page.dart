import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:song/PlaylistSongListPage.dart';
import 'dart:convert';
import 'service/url.dart'; 

class PlaylistSongPage extends StatefulWidget {
  const PlaylistSongPage({super.key});

  @override
  State<PlaylistSongPage> createState() => _PlaylistSongPageState();
}

class _PlaylistSongPageState extends State<PlaylistSongPage> {
  List<dynamic> playlists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
  }

  Future<void> fetchPlaylists() async {
    try {
      final response = await http.get(Uri.parse(Url.playlists));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          playlists = jsonData['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load playlists');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching playlists: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Song Playlist'),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaylistSongListPage(
                          playlistId: playlist['uuid'], playlistName: '',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playlist['playlist_name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '🎵 ${playlist['song_count']} songs',
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blueAccent),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}


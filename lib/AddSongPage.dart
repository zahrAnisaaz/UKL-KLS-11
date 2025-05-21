import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class AddSongPage extends StatefulWidget {
  final String playlistId;

  const AddSongPage({super.key, required this.playlistId});

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

  File? _thumbnail;
  Uint8List? _thumbnailBytes;
  String? _thumbnailName;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _thumbnailName = basename(pickedFile.path);
      });

      if (kIsWeb) {
        _thumbnailBytes = await pickedFile.readAsBytes();
      } else {
        _thumbnail = File(pickedFile.path);
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        (kIsWeb ? _thumbnailBytes == null : _thumbnail == null)) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and pick a thumbnail"),
        ),
      );
      return;
    }

    final uri =
        Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl2/playlists/song');
    final request = http.MultipartRequest('POST', uri)
      ..fields['title'] = _titleController.text
      ..fields['artist'] = _artistController.text
      ..fields['description'] = _descriptionController.text
      ..fields['source'] = _sourceController.text
      ..fields['playlist_id'] = widget.playlistId;

    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'thumbnail',
        _thumbnailBytes!,
        filename: _thumbnailName ?? 'thumbnail.jpg',
      ));
    } else {
      request.files.add(await http.MultipartFile.fromPath(
        'thumbnail',
        _thumbnail!.path,
      ));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text("Song has been created")),
      );
      Navigator.pop(context as BuildContext);
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to add song (status: ${response.statusCode})\n$responseBody",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Song'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(labelText: 'Artist'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter artist' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(labelText: 'YouTube URL'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter YouTube URL' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Choose Thumbnail'),
                onPressed: _pickImage,
              ),
              if (_thumbnail != null || _thumbnailBytes != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_thumbnailName != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(_thumbnailName!),
                      ),
                    if (kIsWeb && _thumbnailBytes != null)
                      Image.memory(_thumbnailBytes!, height: 120)
                    else if (_thumbnail != null)
                      Image.file(_thumbnail!, height: 120),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Save Song'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

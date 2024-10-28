import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:brightapp/controllers/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({super.key});

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  List<XFile>? _imageFileList;
  dynamic _pickImageError;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final TextEditingController _captionController = TextEditingController(); // Caption controller

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
    bool isMultiImage = false,
  }) async {
    try {
      if (isMultiImage) {
        final List<XFile> pickedFileList = await _picker.pickMultiImage();
        setState(() {
          _imageFileList = pickedFileList;
        });
      } else {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        setState(() {
          _imageFileList = pickedFile == null ? null : [pickedFile];
        });
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Future<void> _uploadAndPostImages() async {
    if (_imageFileList == null || _imageFileList!.isEmpty) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String caption = _captionController.text;
    User? user = FirebaseAuth.instance.currentUser; // Get the logged-in user
    String username = user?.displayName ?? 'Anonymous';
    String profilePicture = user?.photoURL ?? 'https://via.placeholder.com/150';
    String userId = user?.uid ?? 'unknown';

    for (XFile imageFile in _imageFileList!) {
      // Upload the image to Firebase
      final imageUrl = await uploadImageToFirebase(imageFile);

      if (imageUrl != null) {
        // Create a post in Firestore within the user's 'posts' subcollection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId) // Go to the specific user's document
            .collection('posts') // Go to the posts subcollection
            .add({
          'imageUrl': imageUrl,
          'caption': caption,
          'username': username,
          'timestamp': FieldValue.serverTimestamp(),
          'userUID': userId,
        });
      }
    }

    setState(() {
      _isUploading = false;
      _imageFileList = null;
      _captionController.clear();
    });

    // Navigate back to home after posting
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _captionController.dispose(); // Dispose of the controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _uploadAndPostImages,
          ),
        ],
      ),
      body: Center(
        child: _isUploading
            ? const CircularProgressIndicator()
            : Column(
                children: [
                  Expanded(child: _previewImages()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _captionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Write a caption...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              _onImageButtonPressed(ImageSource.gallery, context: context);
            },
            heroTag: 'image0',
            tooltip: 'Pick Image from gallery',
            child: const Icon(Icons.photo),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(ImageSource.camera, context: context);
              },
              heroTag: 'image1',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewImages() {
    if (_imageFileList != null) {
      return ListView.builder(
        key: UniqueKey(),
        itemBuilder: (BuildContext context, int index) {
          return kIsWeb
              ? Image.network(_imageFileList![index].path)
              : Image.file(File(_imageFileList![index].path));
        },
        itemCount: _imageFileList!.length,
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }
}

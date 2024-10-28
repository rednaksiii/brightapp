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
  bool _imagesPicked = false; // Step control: tracks if images are picked
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
          _imagesPicked = true; // Move to step 2 once images are picked
        });
      } else {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        setState(() {
          _imageFileList = pickedFile == null ? null : [pickedFile];
          _imagesPicked = true; // Move to step 2 once images are picked
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
        backgroundColor: Colors.white, // Keep the AppBar white and untouched
      ),
      body: Container(
        color: Colors.white, 
        child: Center(
          child: _isUploading
              ? const CircularProgressIndicator()
              : Column(
                  children: [
                    Expanded(
                      child: _imagesPicked ? _previewImages() : _showInitialButtons(), // Step-based display
                    ),
                    if (_imagesPicked)
                      Expanded(
                        child: SingleChildScrollView( // Make Step 2 scrollable
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: _buildCaptionBox(), // Show bigger caption box if images are picked
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: ElevatedButton(
                                  onPressed: _uploadAndPostImages,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white, // White button color
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                  ),
                                  child: const Text('Post', style: TextStyle(fontSize: 16, color: Colors.black)), // Black text color for contrast
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  // Step 1
  Widget _showInitialButtons() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton.icon(
          onPressed: () {
            _onImageButtonPressed(ImageSource.gallery, context: context, isMultiImage: true); // Select multiple images from gallery
          },
          icon: const Icon(Icons.photo),
          label: const Text('Pick from Gallery'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // White button background
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            _onImageButtonPressed(ImageSource.camera, context: context); // Select a photo from camera
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text('Take a Photo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // White button background
          ),
        ),
      ],
    ),
  );
}

  // Step 2: Show the preview of images in half of the screen (fixed square aspect ratio)
  Widget _previewImages() {
    if (_imageFileList != null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5, // Half the screen height
        child: ListView.builder(
          scrollDirection: Axis.horizontal, // Horizontal scrollable images
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.height * 0.4, // Make the width based on height to ensure square
                height: MediaQuery.of(context).size.height * 0.4, // Make the image square-shaped
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16), // Rounded corners
                  child: kIsWeb
                      ? Image.network(
                          _imageFileList![index].path,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_imageFileList![index].path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            );
          },
          itemCount: _imageFileList!.length,
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked any images.',
        textAlign: TextAlign.center,
      );
    }
  }

  // Step 2: Show the caption box (Larger, rectangular shape, white border on focus, no rounded corners)
  Widget _buildCaptionBox() {
    return Container(
      height: 150, // Make the caption box bigger
      child: TextField(
        controller: _captionController,
        maxLines: 4,
        style: const TextStyle(color: Colors.white), // White text inside caption box
        decoration: InputDecoration(
          hintText: 'Write a caption...',
          hintStyle: const TextStyle(color: Colors.white54), // White hint text
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1.5), // White border on focus and thinner
            borderRadius: BorderRadius.circular(10), 
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1.0), // Default white border, thinner
            borderRadius: BorderRadius.circular(10), 
          ),
          fillColor: Colors.grey[800], // Darker fill color for caption box
          filled: true, // Fill the caption box with color
        ),
      ),
    );
  }
}

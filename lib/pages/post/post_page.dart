import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:brightapp/controllers/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool _imagesPicked = false;
  final TextEditingController _captionController = TextEditingController();

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
          _imagesPicked = true;
        });
      } else {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        setState(() {
          _imageFileList = pickedFile == null ? null : [pickedFile];
          _imagesPicked = true;
        });
      }
    } catch (e) {
      print("Image picking error: $e");
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Future<void> _uploadAndPostImages() async {
    if (_imageFileList == null || _imageFileList!.isEmpty) {
      print("No images selected.");
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String caption = _captionController.text;
      User? user = FirebaseAuth.instance.currentUser;
      String username = user?.displayName ?? 'Anonymous';
      String profilePicture = user?.photoURL ?? 'https://via.placeholder.com/150';
      String userId = user?.uid ?? 'unknown';

      print("Uploading images...");
      for (XFile imageFile in _imageFileList!) {
        final imageUrl = await uploadImageToFirebase(imageFile);

        if (imageUrl != null) {
          print("Image uploaded, URL: $imageUrl");
          await createPost(userId, username, profilePicture, imageUrl, caption);
          print("Post created successfully.");
        } else {
          print("Image upload failed for ${imageFile.path}");
        }
      }

      setState(() {
        _isUploading = false;
        _imageFileList = null;
        _captionController.clear();
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error uploading images or creating post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create post.')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: _isUploading
              ? const CircularProgressIndicator()
              : Column(
                  children: [
                    Expanded(
                      child: _imagesPicked ? _previewImages() : _showInitialButtons(),
                    ),
                    if (_imagesPicked)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: _buildCaptionBox(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: ElevatedButton(
                                  onPressed: _uploadAndPostImages,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                  ),
                                  child: const Text('Post', style: TextStyle(fontSize: 16, color: Colors.black)),
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

  Widget _showInitialButtons() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton.icon(
            onPressed: () {
              _onImageButtonPressed(ImageSource.gallery, context: context, isMultiImage: true);
            },
            icon: const Icon(Icons.photo),
            label: const Text('Pick from Gallery'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _onImageButtonPressed(ImageSource.camera, context: context);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take a Photo'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _previewImages() {
    if (_imageFileList != null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.height * 0.4,
                height: MediaQuery.of(context).size.height * 0.4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: kIsWeb
                      ? Image.network(_imageFileList![index].path, fit: BoxFit.cover)
                      : Image.file(File(_imageFileList![index].path), fit: BoxFit.cover),
                ),
              ),
            );
          },
          itemCount: _imageFileList!.length,
        ),
      );
    } else if (_pickImageError != null) {
      return Text('Pick image error: $_pickImageError', textAlign: TextAlign.center);
    } else {
      return const Text('You have not yet picked any images.', textAlign: TextAlign.center);
    }
  }

  Widget _buildCaptionBox() {
    return Container(
      height: 150,
      child: TextField(
        controller: _captionController,
        maxLines: 4,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Write a caption...',
          hintStyle: const TextStyle(color: Colors.white54),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1.0),
            borderRadius: BorderRadius.circular(10),
          ),
          fillColor: Colors.grey[800],
          filled: true,
        ),
      ),
    );
  }
}

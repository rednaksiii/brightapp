import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brightapp/controllers/firebase_services.dart';

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
  bool _editingEnabled = false;
  final TextEditingController _captionController = TextEditingController();
  List<XFile>? _editedImageFiles;

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
          _editedImageFiles = List<XFile>.from(_imageFileList!);
        });
      } else {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        setState(() {
          _imageFileList = pickedFile == null ? null : [pickedFile];
          _imagesPicked = true;
          _editedImageFiles = List<XFile>.from(_imageFileList!);
        });
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

Future<void> _applyFilter(int index) async {
  if (_imageFileList == null || _imageFileList!.isEmpty) return;

  String fileName = path.basename(_imageFileList![index].path);

  // Decode and apply orientation to the image
  img.Image originalImage = img.decodeImage(File(_imageFileList![index].path).readAsBytesSync())!;
  originalImage = img.bakeOrientation(originalImage); // Fix rotation

  // Use PhotoFilterSelector with rounded corners
  Map? imageFile = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) => Scaffold(
        body: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16), // Rounded corners
            child: PhotoFilterSelector(
              title: const Text("Apply Filter"),
              image: originalImage,
              filters: presetFiltersList,
              filename: fileName,
              loader: const Center(child: CircularProgressIndicator()),
              appBarColor: Colors.white,
              fit: BoxFit.contain, // Keep aspect ratio
            ),
          ),
        ),
      ),
    ),
  );

  // Update edited image if filtering was successful
  if (imageFile != null && imageFile.containsKey('image_filtered')) {
    setState(() {
      _editedImageFiles![index] = XFile(imageFile['image_filtered'].path);
    });
  }
}


Future<void> _uploadAndPostImages() async {
  if (_editedImageFiles == null || _editedImageFiles!.isEmpty) return;

  setState(() {
    _isUploading = true;
  });

  String caption = _captionController.text;
  User? user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    print("Error: No authenticated user");
    setState(() => _isUploading = false);
    return;
  }

  String username = user.displayName ?? 'Anonymous';
  print("Posting as username: $username");

  String profilePicture = user.photoURL ?? 'https://via.placeholder.com/150';
  String userId = user.uid;

  for (XFile imageFile in _editedImageFiles!) {
    final imageUrl = await uploadImageToFirebase(imageFile);
    
    if (imageUrl != null) {
      await createPost(imageUrl, caption, userId, username, profilePicture);
    } else {
      print('Image upload failed, skipping post creation.');
    }
  }

  setState(() {
    _isUploading = false;
    _imageFileList = null;
    _captionController.clear();
  });

  if (mounted) Navigator.pop(context);
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
                      child: !_imagesPicked
                          ? _showInitialButtons()
                          : (!_editingEnabled
                              ? _editOptions()
                              : _filteredImageAndCaption()),
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
              _onImageButtonPressed(
                ImageSource.gallery,
                context: context,
                isMultiImage: true,
              );
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

  Widget _editOptions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _editedImageFiles?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => _applyFilter(index), // Apply filter on click
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16), // Rounded corners
                      child: AspectRatio(
                        aspectRatio: 1, // Square aspect ratio
                        child: Image.file(
                          File(_editedImageFiles![index].path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _editingEnabled = true;
              });
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _filteredImageAndCaption() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _editedImageFiles?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                    child: AspectRatio(
                      aspectRatio: 1, // Square aspect ratio
                      child: Image.file(
                        File(_editedImageFiles![index].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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
              child: const Text(
                'Post',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
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

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'dart:typed_data';

// class CustomGalleryPicker extends StatefulWidget {
//   const CustomGalleryPicker({super.key});

//   @override
//   State<CustomGalleryPicker> createState() => _CustomGalleryPickerState();
// }

// class _CustomGalleryPickerState extends State<CustomGalleryPicker> {
//   final ImagePicker picker = ImagePicker();
//   List<AssetEntity> _galleryImages = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchGalleryImages();
//   }

//   Future<void> _fetchGalleryImages() async {
//     final PermissionState ps = await PhotoManager.requestPermissionExtend();
//     if (!ps.hasAccess) {
//       setState(() {
//         _isLoading = false;
//       });
//       return;
//     }

//     final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
//       type: RequestType.image,
//     );
//     if (albums.isNotEmpty) {
//       final List<AssetEntity> images = await albums[0].getAssetListPaged(
//         page: 0,
//         size: 100,
//       );
//       setState(() {
//         _galleryImages = images;
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : GridView.builder(
//                 padding: const EdgeInsets.all(10),
//                 itemCount: _galleryImages.length + 1,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   mainAxisSpacing: 5,
//                   crossAxisSpacing: 5,
//                 ),
//                 itemBuilder: (BuildContext context, int index) {
//                   if (index == 0) {
//                     // Camera icon cell
//                     return GestureDetector(
//                       onTap: () async {
//                         final XFile? cameraImage = await picker.pickImage(
//                           source: ImageSource.camera,
//                         );
//                         if (cameraImage != null) {
//                           Navigator.pop(context); // Close the modal
//                           // Do something with the image (like display it or pass it back)
//                           print("Camera image path: ${cameraImage.path}");
//                         }
//                       },
//                       child: Container(
//                         color: Colors.grey[300],
//                         child: const Icon(
//                           Icons.camera_alt,
//                           size: 30,
//                           color: Colors.black54,
//                         ),
//                       ),
//                     );
//                   } else {
//                     final image = _galleryImages[index - 1];
//                     return GestureDetector(
//                       onTap: () async {
//                         Navigator.pop(context); // Close the modal
//                         final file = await image.file;
//                         print("Gallery image path: ${file?.path}");
//                       },
//                       child: FutureBuilder<Uint8List?>(
//                         future: image.thumbnailDataWithSize(
//                           const ThumbnailSize(200, 200),
//                         ),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Center(
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             );
//                           }
//                           if (snapshot.hasError || snapshot.data == null) {
//                             return const Center(
//                               child: Icon(Icons.broken_image),
//                             );
//                           }
//                           return Image.memory(
//                             snapshot.data!,
//                             fit: BoxFit.cover,
//                           );
//                         },
//                       ),
//                     );
//                   }
//                 },
//               ),
//     );
//   }
// }

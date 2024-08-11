import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Widget bottomSheet(BuildContext context) {
  return Wrap(
    children: [
      ListTile(
        leading: Icon(Icons.camera_alt),
        title: Text('Take Photo'),
        onTap: () {
          Navigator.pop(context, ImageSource.camera);
        },
      ),
      ListTile(
        leading: Icon(Icons.photo_library),
        title: Text('Gallery'),
        onTap: () {
          Navigator.pop(context, ImageSource.gallery);
        },
      ),
      ListTile(
        leading: Icon(Icons.cancel),
        title: Text('Cancel'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    ],
  );
}

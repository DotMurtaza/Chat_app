import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullImageViewScreen extends StatelessWidget {
  final String image;
  FullImageViewScreen({
    required this.image,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        extendBodyBehindAppBar: true,
        body: PhotoView(
          imageProvider: NetworkImage(
            image,
          ),
        ));
  }
}

import 'package:flutter/material.dart';

class DetailImage extends StatefulWidget {
  final image;
  const DetailImage({super.key, required this.image});

  @override
  State<DetailImage> createState() => _DetailImageState();
}

class _DetailImageState extends State<DetailImage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Center(
              child: Hero(
                tag: 'HeorImage',
                child: Image.network(widget.image.toString()),
              ),
            )),
      ),
    );
  }
}

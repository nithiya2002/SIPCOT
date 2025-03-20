import 'package:flutter/material.dart';
import 'package:sipcot/mediaPreviewScreen.dart';





void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaPreviewScreen(
      mediaUrls: [
        "https://dnwrerqo5ddte.cloudfront.net/chn-ban/site-5-soorai-2/image-point-16/point-16-Image-1.jpg",
        "https://dnwrerqo5ddte.cloudfront.net/chn-ban/site-5-soorai-2/image-point-16/point-16-video-1.mp4",
        "https://dnwrerqo5ddte.cloudfront.net/chn-ban/site-5-soorai-2/image-point-16/point-16-Image-2.jpg",
      ],
    ),
    );
  }
}

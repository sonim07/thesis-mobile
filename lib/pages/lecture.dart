import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/localStorage.dart';
import 'package:url_launcher/url_launcher.dart';

class LectureDetailPage extends StatefulWidget {
  final String id;

  const LectureDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  _LectureDetailPageState createState() => _LectureDetailPageState();
}

class _LectureDetailPageState extends State<LectureDetailPage> {
  late Future<List<Map<String, dynamic>>> _lectureDetails;

  @override
  void initState() {
    super.initState();
    _lectureDetails = fetchLectureDetails(widget.id);
  }

  Future<List<Map<String, dynamic>>> fetchLectureDetails(String id) async {
    final String? token = await LocalStorage.getToken();

    if (token == null) {
      throw Exception('Login First to study');
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5500/api/lectures/$id'),
      headers: {
        'token': '$token',
      },
    );

    print('response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['lectures']);
    } else {
      throw Exception('Failed to load lecture details');
    }
  }

  Future<void> _launchInBrowser(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  // Future<void> _launchInWebView(String url) async {
  //   if (!await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView)) {
  //     throw Exception('Could not launch $url');
  //   }
  // }

  // Future<void> _launchInBrowser(String url) async {
  //   if (!await launchUrl(Uri.parse(url))) {
  //     throw 'Could not launch $url';
  //   }
  //   // if (!await launchUrl(
  //   //   Uri.parse(url),
  //   //   // mode: LaunchMode.externalApplication,
  //   // )) {
  //   //   throw 'Could not launch $url';
  //   // }
  // }

  // void _launchURL(String url) async {
  //   final Uri uri = Uri.parse(url);
  //   print('Attempting to launch: $uri');
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lecture Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _lectureDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            final lectures = snapshot.data!;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lectures.map((lecture) {
                    final title = lecture['title'] ?? 'No title available';
                    final description =
                        lecture['description'] ?? 'No description available';
                    final videoUrl = lecture['video'] ?? '';

                    return ExpansionTile(
                      title: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          Colors.blueAccent, // Set text color
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8.0), // Rounded corners
                                      ),
                                      elevation:
                                          5, // Add shadow for better elevation
                                      padding: const EdgeInsets.all(
                                          12.0), // Added padding inside the button
                                    ),
                                    onPressed: () {
                                      _launchInBrowser(
                                          'http://10.0.2.2:5500/$videoUrl');
                                    },
                                    child: Text(
                                      'See Video',
                                      style: TextStyle(
                                        fontSize:
                                            16, // Increased font size for better readability
                                        fontWeight:
                                            FontWeight.bold, // Bold text
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

// class VideoPlayerWidget extends StatefulWidget {
//   final String videoUrl;

//   const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

//   @override
//   _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   late VideoPlayerController _controller;
//   late Future<void> _initializeVideoPlayerFuture;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
//     _initializeVideoPlayerFuture = _controller.initialize();
//     _controller.setLooping(true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<void>(
//       future: _initializeVideoPlayerFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           if (_controller.value.hasError) {
//             return Center(
//                 child: Text('Error: ${_controller.value.errorDescription}'));
//           }
//           return AspectRatio(
//             aspectRatio: _controller.value.aspectRatio,
//             child: VideoPlayer(_controller),
//           );
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else {
//           return Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
// }

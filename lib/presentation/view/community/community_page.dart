import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:geolocator/geolocator.dart';
import '../../../data/repository/user_repository.dart';
import 'community_widgets/post_widget.dart';
import 'create_post_screen.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user.dart';

class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({super.key});

  @override
  _CommunityFeedPageState createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  String? _currentUsername;
  CustomUser? _currentUser;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _getCurrentLocation();
  }

  Future<void> _fetchCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final user = await _userRepository.getUserById(currentUser.uid);
      setState(() {
        _currentUser = user;
        _currentUsername = user?.username ?? "Anonymous";
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
  }

  Widget _buildPostItem(DocumentSnapshot post) {
    final postData = post.data() as Map<String, dynamic>;
    final Post postModel = Post.fromMap(postData, post.id);

    // Check for current user ID before creating the PostWidget
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return const Center(child: Text("User not authenticated"));
    }

    return PostWidget(
      post: postModel,
      currentUserId: currentUserId,
      currentUsername: _currentUsername ?? "Anonymous",
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true, // Ensure the Scaffold resizes to avoid bottom inset
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo[700]!.withOpacity(0.9),
              Colors.indigo[500]!.withOpacity(0.7),
            ],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.bubble_left_bubble_right_fill,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Community',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.indigo[700]!,
            Colors.indigo[200]!,
          ],
          stops: const [0.2, 1.0],
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('posts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CupertinoActivityIndicator(
                      color: Colors.white,
                    ),
                  );
                }
                var posts = snapshot.data!.docs;

                if (_currentPosition != null) {
                  // Optionally filter posts by location here
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 80,
                    left: 12,
                    right: 12,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return _buildPostItem(posts[index]);
                  },
                );
              },
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: Hero(
              tag: 'createPostButton',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.purpleAccent,
                        Colors.deepPurpleAccent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(16),
                    onPressed: () {
                      if (_currentUser != null) {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => PostCreationPage(
                              user: _currentUser!,
                              currentUsername: _currentUsername ?? "Anonymous",
                              currentUser: _auth.currentUser!,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Icon(
                      CupertinoIcons.add,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),

  );
}
}

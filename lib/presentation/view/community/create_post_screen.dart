import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user.dart';

class PostCreationPage extends StatefulWidget {
  final CustomUser user;
  final String currentUsername;
  final User currentUser;

  const PostCreationPage({
    super.key,
    required this.user,
    required this.currentUsername,
    required this.currentUser,
  });

  @override
  _PostCreationPageState createState() => _PostCreationPageState();
}

class _PostCreationPageState extends State<PostCreationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  final int _titleMaxLength = 50;
  final int _contentMaxLength = 300;

  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message.tr(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: "DISMISS".tr(),
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    setState(() => _isLoading = true);

    String title = _titleController.text.trim();
    String content = _contentController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      try {
        Post newPost = Post(
          postId: "",
          userId: widget.user.uid,
          username: widget.user.username,
          title: title,
          content: content,
          likes: [],
          likeCount: 0,
          comments: [],
          timestamp: DateTime.now(),
        );

        DocumentReference postRef = await _firestore.collection("posts").add(newPost.toMap());
        await postRef.update({"postId": postRef.id});

        _showSnackBar(context, "Post created successfully!", Colors.green[700]!);

        Navigator.pop(context);
      } catch (e) {
        _showSnackBar(context, "Failed to create post: $e", Colors.red[700]!);
      }
    } else {
      _showSnackBar(context, "Title and content cannot be empty", Colors.red[700]!);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post",
            style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)).tr(),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: "createPostButton",
                child: Container(), // Placeholder for the hero animation
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Title".tr(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.cardColor,
                  counterText: "${_titleController.text.length}/$_titleMaxLength",
                ),
                style: theme.textTheme.bodyLarge?.copyWith(fontFamily: "Poppins"),
                maxLength: _titleMaxLength,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: "Content".tr(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.cardColor,
                  counterText: "${_contentController.text.length}/$_contentMaxLength",
                ),
                maxLines: 5,
                maxLength: _contentMaxLength,
                style: theme.textTheme.bodyLarge?.copyWith(fontFamily: "Poppins"),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _createPost,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.buttonTheme.colorScheme?.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SpinKitFadingCircle(color: Colors.white, size: 24)
                    : const Text("Create Post", style: TextStyle(fontSize: 18, fontFamily: "Poppins", color: Colors.yellow)).tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
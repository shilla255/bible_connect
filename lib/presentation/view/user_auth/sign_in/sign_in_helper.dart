import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:webview_flutter/webview_flutter.dart';

String getFirebaseErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No user found with this email. Please check your email or sign up.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'invalid-email':
      return 'The email address is invalid. Please check and try again.';
    case 'user-disabled':
      return 'This account has been disabled. Please contact support.';
    case 'too-many-requests':
      return 'Too many failed attempts. Please try again later.';
    default:
      return 'An error occurred during sign in. Please try again.';
  }
}

void openWebView(BuildContext context, String url, String title) {
  final WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(url));

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: WebViewWidget(controller: controller),
      ),
    ),
  );
}
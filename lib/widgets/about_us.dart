import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://docs.google.com/document/d/1c5ONYHTwVDvvoyeL-m3skua2tkYWDCkZ9TxqBgb_Myw/edit?usp=sharing'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
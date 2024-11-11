import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ParentalControlNotice extends StatefulWidget {
  final VoidCallback onConfirmed;

  const ParentalControlNotice({required this.onConfirmed, super.key});

  @override
  _ParentalControlNoticeState createState() => _ParentalControlNoticeState();
}

class _ParentalControlNoticeState extends State<ParentalControlNotice> {
  bool _hasReadDisclaimer = false;

  void _openWebView(String url, String title) {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Parental Guidance Required'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            const Text(
              'This feature includes social interaction. Users under the age of 13 must be supervised by a parent or guardian to comply with our usage policies. Accounts that violate our Terms and Conditions will be subject to suspension.',
            ),
            const SizedBox(height: 20),
            const Text('For detailed information, please review the following:'),
            TextButton(
              onPressed: () => _openWebView(
                'https://docs.google.com/document/d/11s8KSZ10EghhMwvDSN-Cok4N3KWEafwpDJm06rU9Gp0/edit?usp=sharing',
                'Terms & Conditions',
              ),
              child: const Text('Terms & Conditions'),
            ),
            TextButton(
              onPressed: () => _openWebView(
                'https://docs.google.com/document/d/1JW2-Iu2NWnhDoyx4r8J4kqsYu3SqCB8932Atd2qDEus/edit?usp=sharing',
                'Privacy Policy',
              ),
              child: const Text('Privacy Policy'),
            ),
            Row(
              children: [
                Checkbox(
                  value: _hasReadDisclaimer,
                  onChanged: (value) {
                    setState(() {
                      _hasReadDisclaimer = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text('I acknowledge that I have read and understood the information above.'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _hasReadDisclaimer ? widget.onConfirmed : null,
          child: const Text('Proceed'),
        ),
      ],
    );
  }
}

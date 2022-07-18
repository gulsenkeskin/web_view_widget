import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_view_widget/src/menu.dart';
import 'package:web_view_widget/src/navigation_controls.dart';
import 'package:web_view_widget/src/web_view_stack.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(
    const MaterialApp(
      home: WebViewApp(),
    ),
  );
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({Key? key}) : super(key: key);

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  final controller = Completer<WebViewController>();

  // @override
  // void initState() {
  //   if (Platform.isAndroid) {
  //     WebView.platform = SurfaceAndroidWebView();
  //   }
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView'),
        actions: [
          NavigationControls(controller: controller),
          Menu(controller: controller),
        ],
      ),
      /*   body: const WebView(
        initialUrl: 'https://flutter.dev',
      ),*/
      body: WebViewStack(
        controller: controller,
      ),
    );
  }
}

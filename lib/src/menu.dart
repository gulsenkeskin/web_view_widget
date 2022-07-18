import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String kExamplePage = '''
<!DOCTYPE html>
<html lang="en">
<head>
<title>Load file or HTML string example</title>
</head>
<body>

<h1>Local demo page</h1>
<p>
 This is an example page used to demonstrate how to load a local file or HTML
 string using the <a href="https://pub.dev/packages/webview_flutter">Flutter
 webview</a> plugin.
</p>

</body>
</html>
''';

enum _MenuOptions {
  navigationDelegate,
  userAgent,
  javascriptChannel,
  listCookies,
  clearCookies,
  addCookie,
  setCookie,
  removeCookie,
  loadFlutterAsset,
  loadLocalFile,
  loadHtmlString,
}

class Menu extends StatefulWidget {
  const Menu({required this.controller, Key? key}) : super(key: key);
  final Completer<WebViewController> controller;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final CookieManager cookieManager = CookieManager();

  //tüm cookie'lerin listesini alma
  Future<void> _onListCookies(WebViewController controller) async {
    final String cookies =
        await controller.runJavascriptReturningResult('document.cookie');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(cookies.isNotEmpty ? cookies : "Mevcut cookie yok")));
  }

  //tüm cookie'leri temizleme
  /* WebView'daki tüm tanımlama bilgilerini temizlemek için CookieManager sınıfının clearCookies yöntemini kullanın. Bu method CookieManager tanımlama bilgilerini temizlediyse true, temizlenecek tanımlama bilgisi yoksa false döndürür (future<bool>)*/

  Future<void> _onClearCookies() async {
    final hadCookies = await cookieManager
        .clearCookies(); //cookie varsa ve temizlendiyse geriye true yoksa false dönen method
    String message = "Cookie'ler temizlendi";
    if (!hadCookies) {
      message = "Temizlenecek Cookie yok";
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

//cookie ekleme //javascript ile yapılır
  Future<void> _onAddCookie(WebViewController controller) async {
    await controller.runJavascript('''var date= new Date();
 date.setTime(date.getTime()+(30*24*60*60*1000));
  document.cookie = "FirstName=Gülseeeen; expires=" + date.toGMTString();''');
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("cookie eklendi")));
  }

  //setting cookie with cookiemanager

  Future<void> _onSetCookie(WebViewController controller) async {
    await cookieManager.setCookie(
        const WebViewCookie(name: "foo", value: "bar", domain: 'flutter.dev'));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Custom cookie is set")));
  }

  //remove cookie
  Future<void> _onRemoveCookie(WebViewController controller) async {
    await controller.runJavascript(
        'document.cookie="FirstName=Gulseeeen; expires=Thu, 01 Jan 1970 00:00:00 UTC" ');
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("cookie silindi")));
  }

  //yerel dosya yükleme
  Future<void> _onLoadFlutterAssetExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadFlutterAsset('assets/www/index.html');
  }

  // _onLoadLocalFileExample, yolu _prepareLocalFile() yöntemi tarafından döndürülen bir String olarak sağlayarak dosyayı yükler.

  Future<void> _onLoadLocalFileExample(
      WebViewController controller, BuildContext context) async {
    final String pathToIndex = await _prepareLocalFile();

    await controller.loadFile(pathToIndex);
  }

  static Future<String> _prepareLocalFile() async {
    final String tmpDir = (await getTemporaryDirectory()).path;
    final File indexFile = File('$tmpDir/www/index.html');

    await Directory('$tmpDir/www').create(recursive: true);
    await indexFile.writeAsString(kExamplePage);

    return indexFile.path;
  }

  // WebViewController, HTML Stringini argüman olarak verebileceğiniz loadHtmlString adında kullanabileceğiniz bir metoda sahiptir. WebView daha sonra sağlanan HTML sayfasını görüntüler.

  Future<void> _onLoadHtmlStringExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadHtmlString(kExamplePage);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
        future: widget.controller.future,
        builder: (context, controller) {
          return PopupMenuButton<_MenuOptions>(
              onSelected: (value) async {
                switch (value) {
                  case _MenuOptions.navigationDelegate:
                    await controller.data!.loadUrl('https://youtube.com');
                    break;
                  case _MenuOptions.userAgent:
                    final userAgent = await controller.data!
                        .runJavascriptReturningResult('navigator.userAgent');
                    if (!mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(userAgent)));
                    break;
                  /*Bu kod, Public IP Adresi API'sine bir GET isteği göndererek aygıtın IP adresini döndürür. Bu sonuç, SnackBar JavascriptChannel'da postMessage çağrılarak bir SnackBar'da gösterilir.*/
                  case _MenuOptions.javascriptChannel:
                    await controller.data!.runJavascript('''
var req = new XMLHttpRequest();
req.open('GET', "https://api.ipify.org/?format=json");
req.onload = function() {
  if (req.status == 200) {
    let response = JSON.parse(req.responseText);
    SnackBar.postMessage("IP Address: " + response.ip);
  } else {
    SnackBar.postMessage("Error: " + req.status);
  }
}
req.send(); ''');
                    break;

                  case _MenuOptions.clearCookies:
                    await _onClearCookies();
                    break;

                  case _MenuOptions.listCookies:
                    await _onListCookies(controller.data!);
                    break;

                  case _MenuOptions.addCookie:
                    await _onAddCookie(controller.data!);
                    break;

                  case _MenuOptions.setCookie:
                    await _onSetCookie(controller.data!);
                    break;

                  case _MenuOptions.removeCookie:
                    await _onRemoveCookie(controller.data!);
                    break;

                  case _MenuOptions.loadFlutterAsset:
                    await _onLoadFlutterAssetExample(controller.data!, context);
                    break;
                  case _MenuOptions.loadLocalFile:
                    await _onLoadLocalFileExample(controller.data!, context);
                    break;
                  case _MenuOptions.loadHtmlString:
                    await _onLoadHtmlStringExample(controller.data!, context);
                    break;
                }
              },
              itemBuilder: (context) => [
                    const PopupMenuItem<_MenuOptions>(
                        value: _MenuOptions.navigationDelegate,
                        child: Text('Navigate to YouTube')),
                    const PopupMenuItem<_MenuOptions>(
                        value: _MenuOptions.userAgent,
                        child: Text("Show user-agent")),
                    const PopupMenuItem<_MenuOptions>(
                        value: _MenuOptions.javascriptChannel,
                        child: Text("Lookup IP Address")),
                    const PopupMenuItem<_MenuOptions>(
                      value: _MenuOptions.clearCookies,
                      child: Text('Clear cookies'),
                    ),
                    const PopupMenuItem<_MenuOptions>(
                      value: _MenuOptions.listCookies,
                      child: Text('List cookies'),
                    ),
                    const PopupMenuItem<_MenuOptions>(
                      value: _MenuOptions.addCookie,
                      child: Text('Add cookie'),
                    ),
                    const PopupMenuItem<_MenuOptions>(
                      value: _MenuOptions.setCookie,
                      child: Text('Set cookie'),
                    ),
                    const PopupMenuItem<_MenuOptions>(
                      value: _MenuOptions.removeCookie,
                      child: Text('Remove cookie'),
                    ),
                    const PopupMenuItem<_MenuOptions>(
                      value: _MenuOptions.loadFlutterAsset,
                      child: Text('Load Flutter Asset'),
                    ),
                    const PopupMenuItem<_MenuOptions>(
                      value: _MenuOptions.loadHtmlString,
                      child: Text('Load HTML string'),
                    ),
                    const PopupMenuItem<_MenuOptions>(
                      value: _MenuOptions.loadLocalFile,
                      child: Text('Load local file'),
                    ),
                  ]);
        });
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum _MenuOptions {
  navigationDelegate,
  userAgent,
  javascriptChannel,
  listCookies,
  clearCookies,
  addCookie,
  setCookie,
  removeCookie,
}

class Menu extends StatefulWidget {
  const Menu({required this.controller, Key? key}) : super(key: key);
  final Completer<WebViewController> controller;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final CookieManager cookieManager=CookieManager();
  
  //tüm cookie'lerin listesini alma
  Future<void> _onListCookies(WebViewController controller) async{
    final String cookies= await controller.runJavascriptReturningResult('document.cookie');
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cookies.isNotEmpty ? cookies : "Mevcut cookie yok")));
  }

  //tüm cookie'leri temizleme
 /* WebView'daki tüm tanımlama bilgilerini temizlemek için CookieManager sınıfının clearCookies yöntemini kullanın. Bu method CookieManager tanımlama bilgilerini temizlediyse true, temizlenecek tanımlama bilgisi yoksa false döndürür (future<bool>)*/

Future<void> _onClearCookies()async{
  final hadCookies=await cookieManager.clearCookies(); //cookie varsa ve temizlendiyse geriye true yoksa false dönen method
  String message="Cookie'ler temizlendi";
  if(!hadCookies){
    message="Temizlenecek Cookie yok";
  }
  if(!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

//cookie ekleme //javascript ile yapılır
  Future<void> _onAddCookie(WebViewController controller) async{
  await controller.runJavascript('''var date= new Date();
 date.setTime(date.getTime()+(30*24*60*60*1000));
  document.cookie = "FirstName=Gülseeeen; expires=" + date.toGMTString();''');
  if(!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("cookie eklendi")));

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
                        child: Text("Lookup IP Address"))
                  ]);
        });
  }
}

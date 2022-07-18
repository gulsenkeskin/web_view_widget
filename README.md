# web_view_widget
 Flutter WebView widget
 Web içeriğini bir WebView de görüntüleme
 WebView üzerinde yığılmış Flutter widget'larını görüntüleme
 Sayfa yükleme ilerleme event'larına tepki verme //WebViewStack.dart page load events
 WebView'ı WebViewController aracılığıyla kontrol etme
 NavigationDelegate kullanarak web sitelerini engelleme
 JavaScript'ten callback'leri JavascriptChannels ile yönetme
 Çerezleri ayarlama, kaldırma
 HTML içeren varlıklardan, dosyalardan veya stringlerden HTML yükleme ve görüntüleme


 Paketler:
 webview_flutter
 
 path_provider //dosya sisteminde yaygın olarak kullanılan konumları bulmak için bir Flutter eklentisidir.


 Page Load Events
 
 WebView sayfa yükleme döngüsü sırasında tetiklenen üç farklı sayfa yükleme olayı vardır: onPageStarted, onProgress ve onPageFinished.


 Navigation Delegate
 
 Kullanıcı bir bağlantıya tıkladığında NavigationDelegate çağrılır. NavigationDelegate geri araması, WebView'ün navigasyonla devam edip etmediğini kontrol etmek için kullanılabilir
 


Evaluating JavaScript

değer döndürmeyen JavaScript kodu için runJavaScript kullanın ve değer döndüren JavaScript kodu için runJavaScriptReturningResult kullanın.


JavaScript'i etkinleştirmek için, javaScriptMode özelliği JavascriptMode.unrestricted olarak ayarlanmış olarak WebView pencere aracını yapılandırmanız gerekir. Varsayılan olarak, javascriptMode, JavascriptMode.disabled olarak ayarlanmıştır.

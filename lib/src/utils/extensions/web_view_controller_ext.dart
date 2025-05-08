import 'dart:io' as io;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

extension WebViewControllerExtension on InAppWebViewController {
  Future<List<io.Cookie>?> getCookies(String url) async {
    if (url.contains("https://")) {
      url.replaceAll("https://", "");
    }

    if (url[url.length - 1] == '/') {
      url = url.substring(0, url.length - 1);
    }

    CookieManager cookieManager = CookieManager.instance();

    final cookies = await cookieManager.getCookies(
      url: WebUri(url),
      webViewController: this,
    );

    var res = <io.Cookie>[];

    for (final cookie in cookies) {
      var c = io.Cookie(cookie.name, cookie.value);
      c.domain = cookie.domain;
      res.add(c);
    }

    return res;
  }
}

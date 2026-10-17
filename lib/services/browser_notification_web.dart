// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js' as js;

void requestBrowserPermission() {
  try {
    js.context.callMethod('eval', [
      """
      if (typeof Notification !== 'undefined' && Notification.permission === 'default') {
        Notification.requestPermission().then(function(result) {
          console.log('Browser notification permission: ' + result);
        });
      }
      """,
    ]);
  } catch (e) {
    // Ignore error
  }
}

void showBrowserNotification(String title, String body) {
  try {
    final safeTitle = title.replaceAll("'", "\\'").replaceAll("\n", " ");
    final safeBody = body.replaceAll("'", "\\'").replaceAll("\n", " ");
    js.context.callMethod('eval', [
      """
      if (typeof Notification !== 'undefined' && Notification.permission === 'granted') {
        new Notification('$safeTitle', {
          body: '$safeBody',
          icon: 'favicon.png'
        });
      } else {
        console.log('Browser notification blocked. Permission: ' + (typeof Notification !== 'undefined' ? Notification.permission : 'not supported'));
      }
      """,
    ]);
  } catch (e) {
    // Ignore error
  }
}

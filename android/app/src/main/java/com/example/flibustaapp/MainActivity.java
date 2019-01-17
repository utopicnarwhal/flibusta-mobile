package ru.utopicnarwhal.flibusta;

import android.os.Bundle;
import android.media.MediaScannerConnection;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "ru.utopicnarwhal.flibusta/native_methods_channel";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
      new MethodCallHandler() {
        @Override
        public void onMethodCall(MethodCall call, Result result) {
          if (call.method.equals("rescan_folder")) {
            int response = rescanFolder(call.arguments.toString());
    
            if (response != -1) {
                result.success(response);
            } else {
                result.error("UNAVAILABLE", "Not available.", null);
            }
          } else {
              result.notImplemented();
          }
        }
      }
    );
  }
  
  private int rescanFolder(String dir) {
      try {
          MediaScannerConnection.scanFile(this, new String[] {dir}, null, null);
      } catch (Exception e) {
          return -1;
      }
      return 1;
  }
}

package com.NET.netmobile;  // Ajuste para o seu namespace exato (veja AndroidManifest.xml)

import android.os.Bundle;
import android.view.WindowManager;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Isso impede screenshots e gravações de tela em toda esta Activity:
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
    }
}

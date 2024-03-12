package com.example.color_picker_nfc

import io.flutter.embedding.android.FlutterActivity
import android.app.PendingIntent
import android.content.Intent
import android.nfc.NfcAdapter


class MainActivity: FlutterActivity() {
        override fun onResume() {
        super.onResume()
        val intent = Intent(context, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        val pendingIntent = PendingIntent.getActivity(context, 0, intent, 67108864)
        NfcAdapter.getDefaultAdapter(context)?.enableForegroundDispatch(this, pendingIntent, null, null)
    }

    override fun onPause() {
        super.onPause()
        NfcAdapter.getDefaultAdapter(context)?.disableForegroundDispatch(this)
    }
}

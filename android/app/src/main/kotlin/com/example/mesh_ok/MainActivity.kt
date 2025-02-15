package com.example.mesh_ok

import android.app.ComponentCaller
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.LocationManager
import android.net.wifi.WifiManager
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val flutterChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, flutterChannelName)

        Global.p2pController = P2pController(this, flutterChannel)

        flutterChannel.setMethodCallHandler { call, result ->
            log(call.method + "()")
            GlobalScope.launch {
//          lifecycleScope.launch { // Почему-то работает плохо, иногда виснут suspendCoroutine()
                try {
                    when (call.method) {
                        "init" -> init(result)
                        else -> Global.p2pController.handleMethod(call, result)
                    }
                } catch (e: Exception) {
                    loge(e)
                    result.error("$e", null, null)
                }
            }
        }
    }

    private suspend fun init(result: MethodChannel.Result) {
        log("requestPermissions() => " + requestPermissions())
        log("requestWifi() => " + requestWifi())
        log("requestLocation() => " + requestLocation())
        Global.p2pController.init(result)
    }

    private suspend fun requestPermissions() {
        fun notGranted(p: String) =
            ActivityCompat.checkSelfPermission(this, p) != PackageManager.PERMISSION_GRANTED

        listOf(
            android.Manifest.permission.ACCESS_FINE_LOCATION,
            android.Manifest.permission.ACCESS_WIFI_STATE,
            android.Manifest.permission.CHANGE_WIFI_STATE,
        ).forEach {
            if (notGranted(it)) Global.requiredPermissions.add(it)
        }
        if (Build.VERSION.SDK_INT >= 33) {
            val p = android.Manifest.permission.NEARBY_WIFI_DEVICES
            if (notGranted(p)) Global.requiredPermissions.add(p)
        }

        if (Global.requiredPermissions.isNotEmpty()) {
            suspendCoroutine { continuation ->
                Global.requestPermissionsResult = continuation
                ActivityCompat.requestPermissions(
                    this, Global.requiredPermissions.toTypedArray(), 0
                )
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (grantResults.reduce { acc, v -> acc * v } == 0) {
            Global.requestPermissionsResult?.resume(Unit)
        } else {
            Global.requestPermissionsResult?.resumeWithException(Exception("not all required permissions have been granted!"))
        }
    }

    private suspend fun requestWifi() {
        fun notEnabled(): Boolean =
            !(context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager).isWifiEnabled

        if (notEnabled()) {
            suspendCoroutine { continuation ->
                Global.requestActivityResult = continuation
                startActivityForResult(
                    Intent(Settings.ACTION_WIFI_SETTINGS), Global.requestWifiCode
                )
            }
            if (notEnabled()) throw Exception("WiFi is not turned on!")
        }
    }

    private suspend fun requestLocation() {
        fun notEnabled(): Boolean =
            !(context.applicationContext.getSystemService(Context.LOCATION_SERVICE) as LocationManager).isProviderEnabled(
                LocationManager.GPS_PROVIDER
            )
        if (notEnabled()) {
            suspendCoroutine { continuation ->
                Global.requestActivityResult = continuation
                startActivityForResult(
                    Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS), Global.requestLocationCode
                )
            }
            if (notEnabled()) throw Exception("Location is not turned on!")
        }
    }

    // Почему-то этот колбэк не срабатывает
    override fun onActivityResult(
        requestCode: Int, resultCode: Int, data: Intent?, caller: ComponentCaller
    ) {
        log("onActivityResult(): $requestCode, $resultCode")
        super.onActivityResult(requestCode, resultCode, data, caller)
//        when (requestCode) {
//            requestWifiCode -> requestWifiResult?.resume(Unit)
//            requestLocationCode -> requestLocationResult?.resume(Unit)
//        }
    }

    public override fun onResume() {
        log("onResume()")
        super.onResume()
        if (Global.requestActivityResult != null) {
            Global.requestActivityResult!!.resume(Unit)
            Global.requestActivityResult = null
        }
        Global.p2pController.onResume()
    }

    public override fun onPause() {
        super.onPause()
        Global.p2pController.onPause()
    }
}

fun log(msg: String) {
    Log.d(flutterChannelName, msg)
}

fun loge(err: Throwable) {
    Log.e(flutterChannelName, err.toString())
}

fun loge(err: String) {
    Log.e(flutterChannelName, err)
}

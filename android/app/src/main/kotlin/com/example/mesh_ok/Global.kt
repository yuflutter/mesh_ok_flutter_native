package com.example.mesh_ok

import android.util.Log
import kotlin.coroutines.Continuation

const val ok = "OK"
const val flutterChannelName = "WifiP2pMethodChannel"

object Global {
    val requiredPermissions = mutableListOf<String>()
    var requestPermissionsResult: Continuation<Unit>? = null
    var requestSettingsResult: Continuation<Unit>? = null

    lateinit var p2pController: P2pController

//    const val requestWifiCode = 1;
//    var requestWifiResult: Continuation<Unit>? = null
//
//    const val requestLocationCode = 2;
//    var requestLocationResult: Continuation<Unit>? = null
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

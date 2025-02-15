package com.example.mesh_ok

import kotlin.coroutines.Continuation

const val ok = "OK"
const val flutterChannelName = "WifiP2pMethodChannel"

object Global {
    val requiredPermissions = mutableListOf<String>()
    var requestPermissionsResult: Continuation<Unit>? = null

    var requestActivityResult: Continuation<Unit>? = null

    const val requestWifiCode = 1;
//    var requestWifiResult: Continuation<Unit>? = null

    const val requestLocationCode = 2;
//    var requestLocationResult: Continuation<Unit>? = null

    lateinit var p2pController: P2pController
}

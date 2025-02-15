package com.example.mesh_ok

import kotlin.coroutines.Continuation

const val flutterChannelName = "WifiP2pMethodChannel"
const val ok = "OK"

val requiredPermissions = mutableListOf<String>()
var requestPermissionsResult: Continuation<Boolean>? = null

var requestActivityResult: Continuation<Unit>? = null

lateinit var p2pController: P2pController

const val requestWifiCode = 1;
//var requestWifiResult: Continuation<Unit>? = null

const val requestLocationCode = 2;
//var requestLocationResult: Continuation<Unit>? = null

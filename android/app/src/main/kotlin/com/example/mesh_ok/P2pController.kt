package com.example.mesh_ok

import android.Manifest
import android.content.Context
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pManager
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking


class P2pController(
    private val activity: MainActivity,
    private val flutterChannel: MethodChannel,
) {
    private val intentFilter = IntentFilter()
    private var broadcastReceiver: P2pBroadcastReceiver? = null

    lateinit var p2pManager: WifiP2pManager
    lateinit var p2pChannel: WifiP2pManager.Channel

    private val peers = mutableListOf<WifiP2pDevice>()

    fun handleMethod(call: MethodCall, result: MethodChannel.Result) {
        log(call.method + "()")
        runBlocking {
            launch {
                try {
                    when (call.method) {
                        "init" -> init(result)
                        "discoverPeers" -> discoverPeers(result)
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    loge(e)
                    result.error("$e", null, null)
                }
            }
        }
    }

    suspend fun init(result: MethodChannel.Result) {
        try {
            // Indicates a change in the Wi-Fi Direct status.
            intentFilter.addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
            // Indicates a change in the list of available peers.
            intentFilter.addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
            // Indicates the state of Wi-Fi Direct connectivity has changed.
            intentFilter.addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
            // Indicates this device's details have changed.
            intentFilter.addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)

            broadcastReceiver = P2pBroadcastReceiver(this)
            activity.registerReceiver(broadcastReceiver, intentFilter)

            p2pManager = activity.getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager
            p2pChannel = p2pManager.initialize(activity, activity.mainLooper, null)
            result.success(ok)
        } catch (e: Exception) {
            result.error(e.toString(), null, null)
        }
    }


    private suspend fun discoverPeers(result: MethodChannel.Result) {
        if (ActivityCompat.checkSelfPermission(
                activity, Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return result.error("required permissions is not granted", null, null)
        }

        p2pManager.discoverPeers(p2pChannel, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                result.success(ok)
            }

            override fun onFailure(reasonCode: Int) {
                val msg = "discoverPeers() => $reasonCode"
                loge(msg)
                result.error(msg, null, null)
            }
        })
    }

    val peersListener = WifiP2pManager.PeerListListener { peerList ->
        val refreshedPeers = peerList.deviceList
        log("discovered peers: ${refreshedPeers.count()}")
        if (refreshedPeers != peers) {
            peers.clear()
            peers.addAll(refreshedPeers)
            val peersDto =
                peers.map {
                    it.convertObjectToMap()
//                    mapOf(
//                        "deviceName" to e.deviceName,
//                        "deviceAddress" to e.deviceAddress,
//                        "status" to e.status,
//                        "primaryDeviceType" to e.primaryDeviceType,
//                    )
                }.toList()
            flutterChannel.invokeMethod("onPeersDiscovered", peersDto)
        }
//        if (peers.isEmpty()) {
//            log("no peers discovered")
//            return@PeerListListener
//        }
    }

    fun onResume() {
        if (broadcastReceiver != null)
            activity.registerReceiver(broadcastReceiver, intentFilter)
    }

    fun onPause() {
        if (broadcastReceiver != null)
            activity.unregisterReceiver(broadcastReceiver)
    }
}


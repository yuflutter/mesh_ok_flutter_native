package com.example.mesh_ok

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.NetworkInfo
import android.net.wifi.WpsInfo
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

class P2pController(
    activity: MainActivity,
    flutterEngine: FlutterEngine,
) {
    val flutterChannel =
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, flutterChannelName)

    private val p2pManager =
        activity.getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager
    private val p2pChannel =
        p2pManager.initialize(activity, activity.mainLooper, null)

    val intentFilter = IntentFilter()
    val broadcastReceiver = P2pBroadcastReceiver()

    private val peers = mutableListOf<WifiP2pDevice>()

    init {
        // Indicates a change in the Wi-Fi Direct status.
        intentFilter.addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
        // Indicates a change in the list of available peers.
        intentFilter.addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
        // Indicates the state of Wi-Fi Direct connectivity has changed.
        intentFilter.addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
        // Indicates this device's details have changed.
        intentFilter.addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
    }

    fun handleMethod(call: MethodCall, result: MethodChannel.Result) {
        log(call.method + "()")
        runBlocking {
            launch {
                try {
                    when (call.method) {
                        "init" -> init(result)
                        "discoverPeers" -> discoverPeers(result)
                        "connectPeer" -> connectPeer(call.arguments as String, result)
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    loge(e)
                    result.error("$e", null, null)
                }
            }
        }
    }

    fun init(result: MethodChannel.Result) {
        try {
            // тут что-то было, но ушло в init{}
            result.success(ok)
        } catch (e: Exception) {
            result.error(e.toString(), null, null)
        }
    }


    @SuppressLint("MissingPermission")
    private fun discoverPeers(result: MethodChannel.Result) {
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

    val discoverPeersListener = WifiP2pManager.PeerListListener { peerList ->
        val refreshedPeers = peerList.deviceList
        log("discovered peers: ${refreshedPeers.count()}")
        if (refreshedPeers != peers) {
            peers.clear()
            peers.addAll(refreshedPeers)
            val peersDto = peers.map { it.convertObjectToMap() }.toList()
            flutterChannel.invokeMethod("onPeersDiscovered", peersDto)
        }
    }

    @SuppressLint("MissingPermission")
    private fun connectPeer(peerAddress: String, result: MethodChannel.Result) {
        val peer = peers.find { it.deviceAddress == peerAddress }
        if (peer == null) {
            return result.error("Peer $peerAddress is fot found", null, null)
        }
        log(peer.toString())
        val config = WifiP2pConfig().apply {
            deviceAddress = peer.deviceAddress
            wps.setup = WpsInfo.PBC
        }
        p2pManager.connect(p2pChannel, config, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                result.success(ok)
            }

            override fun onFailure(reason: Int) {
                result.error("connectPeer() => $reason", null, null)
            }
        })
    }

    val connectPeerListener = WifiP2pManager.ConnectionInfoListener { info ->
        log("WifiP2pInfo: $info")

        val groupOwnerAddress = info.groupOwnerAddress.hostAddress

        // After the group negotiation, we can determine the group owner
        // (server).
        if (info.groupFormed && info.isGroupOwner) {
            // Do whatever tasks are specific to the group owner.
            // One common case is creating a group owner thread and accepting
            // incoming connections.
        } else if (info.groupFormed) {
            // The other device acts as the peer (client). In this case,
            // you'll want to create a peer thread that connects
            // to the group owner.
        }
    }

    inner class P2pBroadcastReceiver() : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                // Determine if Wi-Fi Direct mode is enabled or not, alert
                // the Activity.
                WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION -> {
                    val state = intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, -1)
//                activity.isWifiP2pEnabled = state == WifiP2pManager.WIFI_P2P_STATE_ENABLED
                    log("WIFI_P2P_STATE_CHANGED => $state")
                }
                // The peer list has changed! We should probably do something about
                // that.
                WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> {
                    // Request available peers from the wifi p2p manager. This is an
                    // asynchronous call and the calling activity is notified with a
                    // callback on PeerListListener.onPeersAvailable()
                    log("WIFI_P2P_PEERS_CHANGED")
                    try {
                        p2pManager.requestPeers(
                            p2pChannel,
                            discoverPeersListener
                        )
                    } catch (e: SecurityException) {
                        loge(e)
                    }
                }

                // Connection state changed! We should probably do something about
                // that.
                WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                    log("WIFI_P2P_CONNECTION_CHANGED")
                    p2pManager.let { manager ->

                        val networkInfo: NetworkInfo? = intent
                            .getParcelableExtra(WifiP2pManager.EXTRA_NETWORK_INFO) as NetworkInfo?

                        log("NetworkInfo: $networkInfo")

                        if (networkInfo?.isConnected == true) {
                            // We are connected with the other device, request connection
                            // info to find group owner IP
                            manager.requestConnectionInfo(p2pChannel, connectPeerListener)
                        }
                    }

                }

                WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION -> {
                    log("WIFI_P2P_THIS_DEVICE_CHANGE")
//                (activity.supportFragmentManager.findFragmentById(R.id.frag_list) as DeviceListFragment)
//                    .apply {
//                        updateThisDevice(
//                            intent.getParcelableExtra(
//                                WifiP2pManager.EXTRA_WIFI_P2P_DEVICE) as WifiP2pDevice
//                        )
//                    }
                }
            }
        }
    }
}


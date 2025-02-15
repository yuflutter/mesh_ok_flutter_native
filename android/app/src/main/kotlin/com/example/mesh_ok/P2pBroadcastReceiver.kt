package com.example.mesh_ok

import android.content.Context
import android.content.Intent
import android.content.BroadcastReceiver
import android.net.wifi.p2p.WifiP2pManager

class P2pBroadcastReceiver(private val p2pController: P2pController) : BroadcastReceiver() {
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
                    p2pController.p2pManager.requestPeers(
                        p2pController.p2pChannel,
                        p2pController.peersListener
                    )
                } catch (e: SecurityException) {
                    loge(e)
                }
            }

            // Connection state changed! We should probably do something about
            // that.
            WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                log("WIFI_P2P_CONNECTION_CHANGED")
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

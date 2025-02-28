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
import android.net.wifi.p2p.WifiP2pInfo
import android.net.wifi.p2p.WifiP2pManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class P2pController(
    activity: MainActivity,
    flutterEngine: FlutterEngine,
) {
    val flutterChannel =
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, flutterChannelName)

    private val p2pManager = activity.getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager
    private val p2pChannel = p2pManager.initialize(activity, activity.mainLooper, null)

    val intentFilter = IntentFilter()
    val broadcastReceiver = P2pBroadcastReceiver()

    private val peers = mutableListOf<WifiP2pDevice>()
    private var currentP2pInfo: WifiP2pInfo? = null

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
        try {
            when (call.method) {
                "init" -> init(result)
                "requestDeviceInfo" -> requestDeviceInfo(result)
                "requestConnectionInfo" -> requestConnectionInfo(result)
                "requestGroupInfo" -> requestGroupInfo(result)
                "discoverPeers" -> discoverPeers(result)
                "connectPeer" -> connectPeer(call.arguments as String, result)
                "disconnectMe" -> disconnectMe(result)
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            loge(e)
            result.error("$e", null, null)
        }
    }

    private fun onPeersDiscovered(peersDto: List<String>) =
        flutterChannel.invokeMethod("onPeersDiscovered", peersDto)

    private fun onP2pInfoChanged(p2pInfo: String) =
        flutterChannel.invokeMethod("onP2pInfoChanged", p2pInfo)

    fun init(result: MethodChannel.Result) {
        // Важно запросить информацию об устройстве до срабатывания бродкастов
        requestDeviceInfo(result)
    }

    @SuppressLint("MissingPermission")
    private fun requestDeviceInfo(result: MethodChannel.Result) {
        try {
            p2pManager.requestDeviceInfo(p2pChannel) { deviceInfo ->
                log("WifiP2pDevice: $deviceInfo")
                result.success(deviceInfo.convertObjectToJson())
            }
        } catch (e: Throwable) {
            loge(e)
            result.error("$e", null, null)
        }
    }

    private fun requestConnectionInfo(result: MethodChannel.Result? = null) {
        try {
            p2pManager.requestConnectionInfo(p2pChannel) { p2pInfo ->
                log("WifiP2pInfo: $p2pInfo")
                // After the group negotiation, we can determine the group owner (server).
                if (p2pInfo.groupFormed && p2pInfo.isGroupOwner) {
                    // Do whatever tasks are specific to the group owner.
                    // One common case is creating a group owner thread and accepting
                    // incoming connections.
                } else if (p2pInfo.groupFormed) {
                    // The other device acts as the peer (client). In this case,
                    // you'll want to create a peer thread that connects
                    // to the group owner.
                }
                currentP2pInfo = p2pInfo
//                currentNetworkConnectionInfo = NetworkConnectionInfo(
//                    p2pInfo = p2pInfo,
//                    wifiInfo = wifiManager.connectionInfo,
//                    ssid = wifiManager.connectionInfo.ssid,
//                )
                onP2pInfoChanged(currentP2pInfo.convertObjectToJson())
                result?.success(okResult)
            }
        } catch (e: Throwable) {
            loge(e)
            result?.error("$e", null, null)
        }
    }

    @SuppressLint("MissingPermission")
    private fun requestGroupInfo(result: MethodChannel.Result) {
        try {
            p2pManager.requestGroupInfo(p2pChannel) { groupInfo ->
                log("WifiP2pGroup: $groupInfo")
                // TODO: Здесь сериализация почему-то не срабатывает, получаем пустой Map, доделать.
                log("WifiP2pGroupDto: ${groupInfo.convertObjectToJson()}")
                result.success(groupInfo.convertObjectToJson())
            }
        } catch (e: Throwable) {
            loge(e)
            result.error("$e", null, null)
        }
    }

    @SuppressLint("MissingPermission")
    private fun discoverPeers(result: MethodChannel.Result? = null) {
        try {
            p2pManager.discoverPeers(p2pChannel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    result?.success(okResult)
                }

                override fun onFailure(reasonCode: Int) {
                    val msg = "discoverPeers() => ${failureReasonMsg(reasonCode)}"
                    loge(msg)
                    result?.error(msg, null, null)
                }
            })
        } catch (e: Throwable) {
            loge(e)
            result?.error("$e", null, null)
        }
    }

    @SuppressLint("MissingPermission")
    private fun connectPeer(peerAddress: String, result: MethodChannel.Result) {
        val peer = peers.find { it.deviceAddress == peerAddress }
        if (peer == null) {
            return result.error("Peer $peerAddress is fot found", null, null)
        }
        log("Connecting to:\n$peer")
        val config = WifiP2pConfig().apply {
            deviceAddress = peer.deviceAddress
            wps.setup = WpsInfo.PBC
        }
        try {
            p2pManager.connect(p2pChannel, config, object : WifiP2pManager.ActionListener {
                override fun onSuccess() = result.success(okResult)
                override fun onFailure(reasonCode: Int) {
                    val msg = "connectPeer() => ${failureReasonMsg(reasonCode)}"
                    loge(msg)
                    result.error(msg, null, null)
                }
            })
        } catch (e: Throwable) {
            loge(e)
            result.error("$e", null, null)
        }
    }

    private fun disconnectMe(result: MethodChannel.Result) {
        try {
            // роль сервера
            if (currentP2pInfo?.isGroupOwner == false) {
                // TODO: разобраться как правильно удалить себя из группы, не удаляя группу
                p2pManager.removeGroup(p2pChannel, object : WifiP2pManager.ActionListener {
                    override fun onSuccess() = result.success(okResult)
                    override fun onFailure(reasonCode: Int) {
                        val msg = "removeGroup() => ${failureReasonMsg(reasonCode)}"
                        loge(msg)
                        result.error(msg, null, null)
                    }
                })
                // роль клиента
            } else if (currentP2pInfo?.isGroupOwner == true) {
                p2pManager.removeGroup(p2pChannel, object : WifiP2pManager.ActionListener {
                    override fun onSuccess() = result.success(okResult)
                    override fun onFailure(reasonCode: Int) {
                        val msg = "removeGroup() => ${failureReasonMsg(reasonCode)}"
                        loge(msg)
                        result.error(msg, null, null)
                    }
                })
            }
        } catch (e: Throwable) {
            loge(e)
            result.error("$e", null, null)
        }
    }

    inner class P2pBroadcastReceiver() : BroadcastReceiver() {
        @SuppressLint("MissingPermission")
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                // Determine if Wi-Fi Direct mode is enabled or not
                WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION -> {
                    val state = intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, -1)
                    log("WIFI_P2P_STATE_CHANGED_ACTION => $state")
                }

                WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> {
                    log("WIFI_P2P_PEERS_CHANGED_ACTION")
                    try {
                        p2pManager.requestPeers(p2pChannel) { peerList ->
                            val newPeers = peerList.deviceList
                            log("Discovered peers: ${newPeers.count()}")
                            // TODO: сделать глубокое сравнение, чтобы не дублировать вызовы
//                            if (newPeers != peers) {
                            peers.clear()
                            peers.addAll(newPeers)
                            val peersDto = peers.map { it.convertObjectToJson() }.toList()
                            onPeersDiscovered(peersDto)
//                            }
                        }
                    } catch (e: Exception) {
                        loge(e)
                    }
                }

                WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                    log("WIFI_P2P_CONNECTION_CHANGED")
                    val networkInfo =
                        intent.getParcelableExtra(WifiP2pManager.EXTRA_NETWORK_INFO) as NetworkInfo?
                    log("NetworkInfo: $networkInfo")
                    if (networkInfo?.isConnected == true) {
                        // We are connected with the other device, request connection info to find group owner IP
                        requestConnectionInfo()
                    } else {
                        onP2pInfoChanged(errResult("Disconnected"))
                    }
//                    discoverPeers() // возобновляем поиск пиров
                }

                WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION -> {
                    val p2pDevice =
                        intent.getParcelableExtra(WifiP2pManager.EXTRA_WIFI_P2P_DEVICE) as WifiP2pDevice?
                    log("WIFI_P2P_THIS_DEVICE_CHANGE => ${p2pDevice.convertObjectToJson()}")
                }
            }
        }
    }
}

private fun failureReasonMsg(reasonCode: Int): String = when (reasonCode) {
    WifiP2pManager.P2P_UNSUPPORTED -> "WifiP2pManager.P2P_UNSUPPORTED"
    WifiP2pManager.BUSY -> "WifiP2pManager.BUSY"
    WifiP2pManager.ERROR -> "WifiP2pManager.ERROR"
    else -> "WifiP2pManager.$reasonCode"
}

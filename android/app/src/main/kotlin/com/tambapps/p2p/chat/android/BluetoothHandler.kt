package com.tambapps.p2p.chat.android

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.Context
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.IOException
import java.util.*

class BluetoothHandler(private val context: Context) {
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private var socket: BluetoothSocket? = null
    
    // UUID for Serial Port Profile
    private val MY_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

    fun setupMethodChannel(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tambapps/bluetooth").setMethodCallHandler { call, result ->
            when (call.method) {
                "getBluetoothAddress" -> {
                    result.success(bluetoothAdapter?.address ?: "")
                }
                "scanBluetoothDevices" -> {
                    CoroutineScope(Dispatchers.IO).launch {
                        val devices = scanDevices()
                        withContext(Dispatchers.Main) {
                            result.success(devices)
                        }
                    }
                }
                "connectToDevice" -> {
                    val address = call.argument<String>("address")
                    if (address != null) {
                        CoroutineScope(Dispatchers.IO).launch {
                            val connected = connectToDevice(address)
                            withContext(Dispatchers.Main) {
                                result.success(connected)
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Device address is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun scanDevices(): List<String> {
        val pairedDevices = bluetoothAdapter?.bondedDevices
        val devicesList = mutableListOf<String>()
        
        pairedDevices?.forEach { device ->
            devicesList.add("${device.name}|${device.address}")
        }
        
        return devicesList
    }

    private fun connectToDevice(address: String): Boolean {
        try {
            val device = bluetoothAdapter?.getRemoteDevice(address)
            socket = device?.createRfcommSocketToServiceRecord(MY_UUID)
            socket?.connect()
            return socket?.isConnected ?: false
        } catch (e: IOException) {
            socket?.close()
            return false
        }
    }

    fun closeConnection() {
        try {
            socket?.close()
        } catch (e: IOException) {
            // Handle error
        }
    }
}
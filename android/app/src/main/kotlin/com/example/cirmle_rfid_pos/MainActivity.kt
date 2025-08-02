package com.example.cirmle_rfid_pos

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.Intent
import org.json.JSONObject
import java.util.HashMap

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.cirmle_rfid_pos/razorpay_pos"
    private val NEPTUNE_CHANNEL = "com.example.cirmle_rfid_pos/neptune_card"
    private var razorpayPOSHandler: RazorpayPOSHandler? = null
    private var neptuneCardHandler: NeptuneCardHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        razorpayPOSHandler = RazorpayPOSHandler(this)
        neptuneCardHandler = NeptuneCardHandler(this)
        
        // Set up Razorpay POS channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeSDK" -> {
                    val appKey = call.argument<String>("appKey") ?: ""
                    val username = call.argument<String>("username") ?: ""
                    val mode = call.argument<String>("mode") ?: "DEMO"
                    val prepareDevice = call.argument<Boolean>("prepareDevice") ?: false
                    
                    razorpayPOSHandler?.initializeSDK(appKey, username, mode, prepareDevice) { response ->
                        result.success(response)
                    }
                }
                "makePayment" -> {
                    val paymentData = call.arguments as? Map<String, Any> ?: emptyMap()
                    razorpayPOSHandler?.makePayment(paymentData) { response ->
                        result.success(response)
                    }
                }
                "cardPayment" -> {
                    val paymentData = call.arguments as? Map<String, Any> ?: emptyMap()
                    razorpayPOSHandler?.cardPayment(paymentData) { response ->
                        result.success(response)
                    }
                }
                "upiPayment" -> {
                    val paymentData = call.arguments as? Map<String, Any> ?: emptyMap()
                    razorpayPOSHandler?.upiPayment(paymentData) { response ->
                        result.success(response)
                    }
                }
                "cashPayment" -> {
                    val paymentData = call.arguments as? Map<String, Any> ?: emptyMap()
                    razorpayPOSHandler?.cashPayment(paymentData) { response ->
                        result.success(response)
                    }
                }
                "voidPayment" -> {
                    val txnId = call.argument<String>("txnId") ?: ""
                    razorpayPOSHandler?.voidPayment(txnId) { response ->
                        result.success(response)
                    }
                }
                "getTransactionStatus" -> {
                    val txnId = call.argument<String>("txnId") ?: ""
                    razorpayPOSHandler?.getTransactionStatus(txnId) { response ->
                        result.success(response)
                    }
                }
                "printReceipt" -> {
                    val txnId = call.argument<String>("txnId") ?: ""
                    razorpayPOSHandler?.printReceipt(txnId) { response ->
                        result.success(response)
                    }
                }
                "closeSDK" -> {
                    razorpayPOSHandler?.closeSDK() { response ->
                        result.success(response)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Set up Neptune card reader channel
        val neptuneChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NEPTUNE_CHANNEL)
        neptuneCardHandler?.setMethodChannel(neptuneChannel)
        
        neptuneChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeSDK" -> {
                    val success = neptuneCardHandler?.initializeSDK() ?: false
                    result.success(success)
                }
                "startCardDetection" -> {
                    val success = neptuneCardHandler?.startCardDetection() ?: false
                    result.success(success)
                }
                "stopCardDetection" -> {
                    val success = neptuneCardHandler?.stopCardDetection() ?: false
                    result.success(success)
                }
                "readCardUID" -> {
                    val uid = neptuneCardHandler?.readCardUID()
                    result.success(uid)
                }
                "writeToCard" -> {
                    val uid = call.argument<String>("uid") ?: ""
                    val data = call.argument<String>("data") ?: ""
                    val block = call.argument<Int>("block") ?: 4
                    val success = neptuneCardHandler?.writeToCard(uid, data, block) ?: false
                    result.success(success)
                }
                "readFromCard" -> {
                    val uid = call.argument<String>("uid") ?: ""
                    val block = call.argument<Int>("block") ?: 4
                    val data = neptuneCardHandler?.readFromCard(uid, block)
                    result.success(data)
                }
                "getDeviceSerial" -> {
                    val serial = neptuneCardHandler?.getDeviceSerial()
                    result.success(serial)
                }
                "isDeviceConnected" -> {
                    val connected = neptuneCardHandler?.isDeviceConnected() ?: false
                    result.success(connected)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        razorpayPOSHandler?.onActivityResult(requestCode, resultCode, data)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        neptuneCardHandler?.cleanup()
    }
}

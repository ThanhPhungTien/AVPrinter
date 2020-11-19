package vn.anvui.flutter_thermal_printer

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.*
import kotlin.collections.ArrayList

class MainActivity : FlutterActivity() {

    private val channel = "com.flutter.bluetooth/bluetooth"
    private lateinit var pairedDevices: Set<BluetoothDevice>
    private lateinit var bluetoothAdapter: BluetoothAdapter
    private var mBTDevices = ArrayList<BluetoothDevice>()
    private lateinit var bluetoothSocket: BluetoothSocket
    private lateinit var outputStream: OutputStream
    private lateinit var inputStream: InputStream

    @Volatile
    var stopWorker = false
    private lateinit var readBuffer: ByteArray
    private var readBufferPosition = 0
    private var thread: Thread? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val pm: PackageManager = context.packageManager
        val hasBluetooth: Boolean = pm.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)
        if (hasBluetooth) {
            bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        }
        mBTDevices = ArrayList()
    }


    override fun onDestroy() {
        super.onDestroy()
        disconnectBT()
        Toast.makeText(baseContext, "onDestroy", Toast.LENGTH_SHORT).show()
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {

                "getList" -> {
                    val myListString = getPairedList()
                    result.success(JSONArray(myListString).toString())
                }

                "connectDevice" -> {
                    val index = call.argument<Int>("index")
                    if (index != null) {
                        onItemClick(index)
                    }
                }
                "printImage" -> {
                    val byteArray = call.argument<ByteArray>("byte")
                    val bitmap: Bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray!!.size)
                    printPhoto(bitmap)
                }
                
            }
        }
    }

    // Lấy danh sách những thiết bị bluetooth đã từng kết nối//

    private fun getPairedList(): ArrayList<String> {
        pairedDevices = bluetoothAdapter.bondedDevices
        val list = ArrayList<String>()
        if (pairedDevices.isEmpty()) {
            Toast.makeText(applicationContext, "There is no paired device ", Toast.LENGTH_SHORT).show()

        } else {
            for (bt in pairedDevices as MutableSet<BluetoothDevice>) {
                list.add(bt.name)
                mBTDevices.add(bt)
            }

            return list
        }
        for (bt in pairedDevices as MutableSet<BluetoothDevice>) {
            list.add(bt.name)
            mBTDevices.add(bt)
        }

        return list

    }

    // chọn thiết bị trong danh sách đã từng kết nối
    private fun onItemClick(i: Int) {
        bluetoothAdapter.cancelDiscovery()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            mBTDevices[i].createBond()
        }
        try {
            openBluetoothPrinter(mBTDevices[i])
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
    }

    // Open Bluetooth Printer
    @Throws(IOException::class)
    fun openBluetoothPrinter(bluetoothDevice: BluetoothDevice) {
        try {
            //Standard uuid from string //
            val uuidSting = UUID.fromString("00001101-0000-1000-8000-00805f9b34fb")
            bluetoothSocket = bluetoothDevice.createRfcommSocketToServiceRecord(uuidSting)
            bluetoothSocket.connect()
            outputStream = bluetoothDevice.createRfcommSocketToServiceRecord(uuidSting).outputStream
            inputStream = bluetoothDevice.createRfcommSocketToServiceRecord(uuidSting).inputStream
            beginListenData()
        } catch (ignored: java.lang.Exception) {
        }
    }

    // tạo cổng nghe từ điện thoại với máy in bluetooth
    private fun beginListenData() {
        try {
            //    final Handler handler = new Handler();
            val delimiter: Byte = 10
            stopWorker = false
            readBufferPosition = 0
            readBuffer = ByteArray(1024)
            thread = Thread {
                while (!Thread.currentThread().isInterrupted && !stopWorker) {
                    try {
                        val byteAvailable = inputStream.available()
                        if (byteAvailable > 0) {
                            val packetByte = ByteArray(byteAvailable)
                            inputStream.read(packetByte)
                            for (i in 0 until byteAvailable) {
                                val encodedByte = ByteArray(readBufferPosition)
                                System.arraycopy(
                                        readBuffer, 0,
                                        encodedByte, 0,
                                        encodedByte.size
                                )
                                readBufferPosition = 0
                            }
                        }
                    } catch (ex: java.lang.Exception) {
                        stopWorker = true
                    }
                }
            }
            thread!!.start()
        } catch (ex: java.lang.Exception) {
            ex.printStackTrace()
        }
    }

    // in ảnh từ dữ liệu bitmap truyền vào

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun printPhoto(bitmap: Bitmap) {
        try {
            outputStream = bluetoothSocket.outputStream
//         val bitmap1 = Bitmap.createBitmap(500, 200, Bitmap.Config.ARGB_8888)
            val command = Utils.decodeBitmap(bitmap)
            outputStream.write(command)
            outputStream.write(PrinterCommands.ESC_ALIGN_CENTER)
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
            Log.e("PrintTools", "the file isn't exists")
        }
    }

    // Ngắt kết nối với máy in 
    @Throws(IOException::class)
    fun disconnectBT() {
        try {
            stopWorker = true
            outputStream.close()
            inputStream.close()
            bluetoothSocket.close()
        } catch (ex: java.lang.Exception) {
            ex.printStackTrace()
        }
    }

}

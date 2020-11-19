import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:avwidget/av_button_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'blutooth_paired_devices/bluetooth_paired_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Thermal Printer Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Flutter Thermal Printer Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int bluetoothDeviceIndex;
  static const MethodChannel platform =
      MethodChannel('com.flutter.bluetooth/bluetooth');
  GlobalKey key = GlobalKey();
  GlobalKey key1 = GlobalKey();
  GlobalKey key2 = GlobalKey();
  GlobalKey logoKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 40,
          ),
          Row(
            children: <Widget>[
              PairedBluetoothDevices(
                bluetoothDeviceIndex: (int index) {
                  bluetoothDeviceIndex = index;
                },
              ),
              Container(
                width: 20,
              ),
              AVButton(
                height: 40,
                title: 'Kết nối',
                onPressed: () {
                  connectToDevice(bluetoothDeviceIndex);
                },
              ),
            ],
          ),
          Container(
            height: 20,
          ),
          myLogo(context),
          myTicketHeader(context),
          myTicketBody(context),
          qrCode(context),
          Container(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: AVButton(
                height: 40,
                title: 'In Ảnh',
                onPressed: () async {
                  Uint8List bytes = await _capturePng(key);
                  Uint8List bytes1 = await _capturePng(key1);
                  Uint8List bytes2 = await _capturePng(key2);
                  Uint8List bytes3 = await _capturePng(logoKey);

                  printImage(bytes3);
                  printImage(bytes);
                  printImage(bytes1);
                  printImage(bytes2);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget myTicketHeader(BuildContext context) {
    return RepaintBoundary(
      key: key,
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                height: 25,
              ),
              const Text(
                'Vận tải An Vui',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 10,
              ),
              const Text(
                'Điện thoại: (84-28) 34256514',
                style: TextStyle(fontSize: 20),
              ),
              mySeparator(context),
              const Text(
                'THANH TOÁN',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              mySeparator(context),
              Container(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget myTicketBody(BuildContext context) {
    return RepaintBoundary(
      key: key1,
      child: Container(
        color: Colors.white,
        child: Center(
          child: Row(
            children: <Widget>[
              Container(
                width: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Hành khách:',
                    // ignore: prefer_const_literals_to_create_immutables
                    style: TextStyle(fontSize: 20),
                  ),
                  Container(
                    height: 10,
                  ),
                  const Text(
                    'Số ghế:',
                    style: TextStyle(fontSize: 20),
                  ),
                  Container(
                    height: 10,
                  ),
                  const Text(
                    'SĐT:',
                    // ignore: prefer_const_literals_to_create_immutables
                    style: TextStyle(fontSize: 20),
                  ),
                  Container(
                    height: 10,
                  ),
                  const Text(
                    'Mã vé:',
                    // ignore: prefer_const_literals_to_create_immutables
                    style: TextStyle(fontSize: 20),
                  ),
                  Container(
                    height: 10,
                  ),
                  const Text(
                    'Tổng tiền:',
                    // ignore: prefer_const_literals_to_create_immutables
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              Container(
                width: 25,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  const Text(
                    'Nguyễn Hoàng Phúc',
                    style: TextStyle(fontSize: 20),
                  ),
                  Container(
                    height: 10,
                  ),
                  const Text(
                    '69A',
                    style: TextStyle(fontSize: 20),
                  ),
                  Container(
                    height: 10,
                  ),
                  const Text(
                    '0904935565',
                    style: TextStyle(fontSize: 20),
                  ),
                  Container(
                    height: 10,
                  ),
                  const Text(
                    '6969696969696',
                    style: TextStyle(fontSize: 20),
                  ),
                  Container(
                    height: 10,
                  ),
                  const Text(
                    '70,000 Đ',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget qrCode(BuildContext context) {
    return RepaintBoundary(
      key: key2,
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            const Center(
              child: ImageIcon(
                AssetImage('assets/qrcode.png'),
                size: 200,
              ),
            ),
            Container(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget myLogo(BuildContext context) {
    return RepaintBoundary(
      key: logoKey,
      child: Container(
        color: Colors.white,
        child: SvgPicture.asset(
          'assets/logo.svg',
          height: 100,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget customerInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Hành khách:',
          style: TextStyle(fontSize: 16),
        ),
        // Container(
        //   height: 10,
        // ),
        const Text(
          'Giá tiền:',
          style: TextStyle(fontSize: 16),
        ),
        Container(
          height: 10,
        ),
        const Text(
          'Số ghế:',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget mySeparator(BuildContext context) {
    return const Text(
      '_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _',
      style: TextStyle(fontSize: 20),
    );
  }

  Future<Uint8List> _capturePng(GlobalKey globalKey) async {
    final RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject() as RenderRepaintBoundary;
    print(boundary.isRepaintBoundary);
    final ui.Image image = await boundary.toImage();
    final ByteData byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData.buffer.asUint8List();
    return pngBytes;
    // print(pngBytes);
  }

  Future<void> connectToDevice(int index) async {
    try {
      await platform.invokeMethod<dynamic>(
          'connectDevice', <String, dynamic>{'index': index});
    } on PlatformException catch (e) {
      print('ERROR ERROR ERROR ===============$e');
    }
  }

  Future<void> printImage(Uint8List byte) async {
    try {
      await platform
          .invokeMethod<dynamic>('printImage', <String, dynamic>{'byte': byte});
    } on PlatformException catch (e) {
      print('ERROR ERROR ERROR ===============$e');
    }
  }
}

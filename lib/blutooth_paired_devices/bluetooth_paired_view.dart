import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_thermal_printer/blutooth_paired_devices/bluetooth_paired_bloc.dart';

class PairedBluetoothDevices extends StatefulWidget {
  const PairedBluetoothDevices({Key key, this.bluetoothDeviceIndex})
      : super(key: key);

  final ValueChanged<int> bluetoothDeviceIndex;

  @override
  _PairedBluetoothDevicesState createState() => _PairedBluetoothDevicesState();
}

class _PairedBluetoothDevicesState extends State<PairedBluetoothDevices> {
  BluetoothPairedBloc bluetoothPairedBloc = BluetoothPairedBloc();
  static const MethodChannel platform =
      MethodChannel('com.flutter.bluetooth/bluetooth');

  @override
  void initState() {
    getListPairedDevice();
    super.initState();
  }

  @override
  void dispose() {
    bluetoothPairedBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothPairedBloc, BluetoothPairedState>(
      cubit: bluetoothPairedBloc,
      builder: (BuildContext context, BluetoothPairedState state) {
        if (state is ShowBluetoothPairedState) {
          return dropDownList(context, state);
        } else {
          return Container(
            color: Colors.red,
          );
        }
      },
    );
  }

  Widget dropDownList(BuildContext context, ShowBluetoothPairedState state) {
    return GestureDetector(
      onTap: () {
        displayShowModalBottomSheet(context, state.data);
      },
      child: Container(
        height: 40,
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  state.title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.expand_more,
                  color: Colors.blue,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void displayShowModalBottomSheet(
      BuildContext context, List<String> bluetoothDevices) {
    showModalBottomSheet<dynamic>(
      elevation: 40,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 16),
          child: ListView(
            shrinkWrap: true,
//            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              Text(
                'Danh sách thiết bị',
                style: Theme.of(context).textTheme.headline5,
              ),
              Container(
                height: 8,
              ),
              ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bluetoothDevices.length,
                itemBuilder: (BuildContext context, int index) {
                  final String bluetoothDevice = bluetoothDevices[index];
                  return listOfType(bluetoothDevice, index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget listOfType(String bluetoothDevice, int index) {
    return GestureDetector(
      onTap: () {
        widget.bluetoothDeviceIndex(index);
        bluetoothPairedBloc.add(UpdateTitleBluetoothPairedEvent(bluetoothDevice));
        Navigator.pop(context);
      },
      child: ListTile(
        leading: const Icon(Icons.bluetooth),
        title: Text(
          bluetoothDevice,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Future<void> getListPairedDevice() async {
    try {
      final dynamic result = await platform.invokeMethod<dynamic>('getList');

      final List<String> devices = <String>[];
      json.decode(result.toString()).forEach((dynamic item) {
        devices.add(item.toString());
      });
      print('HELLO SHITTY 0 ===== $result');
      print('HELLO SHITTY 1 ===== $devices');
      print('HELLO SHITTY 2 ===== ${devices[1]}');
      print('HELLO SHITTY 2 ===== ${devices[2]}');
      print('HELLO SHITTY 2 ===== ${devices.length}');
      bluetoothPairedBloc.add(GetBluetoothListEvent(devices));
    } on PlatformException catch (e) {
      print('ERROR ERROR ERROR ===============$e');
    }
  }
}

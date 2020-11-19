import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bluetooth_paired_event.dart';

part 'bluetooth_paired_state.dart';

class BluetoothPairedBloc
    extends Bloc<BluetoothPairedEvent, BluetoothPairedState> {
  BluetoothPairedBloc() : super(BluetoothPairedInitial());
  List<String> bluetoothDevices = <String>[];

  @override
  Stream<BluetoothPairedState> mapEventToState(
    BluetoothPairedEvent event,
  ) async* {
    if (event is GetBluetoothListEvent) {
      bluetoothDevices = event.data;
      yield ShowBluetoothPairedState(event.data, 'Danh sách các thiết bị');
    } else if (event is UpdateTitleBluetoothPairedEvent) {
      yield ShowBluetoothPairedState(bluetoothDevices, event.title);
    }
  }
}

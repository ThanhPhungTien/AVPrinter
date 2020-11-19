part of 'bluetooth_paired_bloc.dart';

@immutable
abstract class BluetoothPairedEvent {}

class GetBluetoothListEvent extends BluetoothPairedEvent {
  GetBluetoothListEvent(this.data);

  final List<String> data;
}

class UpdateTitleBluetoothPairedEvent extends BluetoothPairedEvent {
  UpdateTitleBluetoothPairedEvent(this.title);

  final String title;
}

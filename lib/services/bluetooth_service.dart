// lib/services/bluetooth_service.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothConnection? _connection;
  final StreamController<String> _dataController =
      StreamController<String>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  String _buffer = '';
  bool _isConnected = false;

  Stream<String> get dataStream => _dataController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _isConnected;

  Future<List<BluetoothDevice>> getPairedDevices() async {
    return await FlutterBluetoothSerial.instance.getBondedDevices();
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _isConnected = true;
      _connectionController.add(true);

      _connection!.input!.listen(
        _onDataReceived,
        onDone: _onDisconnected,
        onError: (_) => _onDisconnected(),
      );
      return true;
    } catch (e) {
      _isConnected = false;
      _connectionController.add(false);
      return false;
    }
  }

  void _onDataReceived(Uint8List data) {
    _buffer += String.fromCharCodes(data);
    // Parse newline-terminated messages from Arduino
    while (_buffer.contains('\n')) {
      final idx = _buffer.indexOf('\n');
      final msg = _buffer.substring(0, idx).trim();
      _buffer = _buffer.substring(idx + 1);
      if (msg.isNotEmpty) {
        _dataController.add(msg);
      }
    }
  }

  void _onDisconnected() {
    _isConnected = false;
    _connectionController.add(false);
    _connection = null;
  }

  Future<void> disconnect() async {
    await _connection?.close();
    _onDisconnected();
  }

  void sendCommand(String command) {
    if (_isConnected && _connection != null) {
      try {
        _connection!.output.add(Uint8List.fromList(command.codeUnits));
      } catch (_) {
        _onDisconnected();
      }
    }
  }

  void dispose() {
    _dataController.close();
    _connectionController.close();
    _connection?.close();
  }
}

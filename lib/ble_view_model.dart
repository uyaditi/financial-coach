// ble_transfer_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

class BLETransferViewModel extends ChangeNotifier {
  List<ScanResult> _devices = [];
  bool _isScanning = false;
  ScanResult? _selectedDevice;
  TransferStatus _transferStatus = TransferStatus.idle;
  String? _errorMessage;

  List<ScanResult> get devices => _devices;
  bool get isScanning => _isScanning;
  ScanResult? get selectedDevice => _selectedDevice;
  TransferStatus get transferStatus => _transferStatus;
  String? get errorMessage => _errorMessage;

  // Start scanning for BLE devices
  Future<void> startScan() async {
    try {
      _isScanning = true;
      _devices.clear();
      _errorMessage = null;
      notifyListeners();

      // Check if Bluetooth is available
      if (await FlutterBluePlus.isSupported == false) {
        throw Exception("Bluetooth not supported by this device");
      }

      // Check Bluetooth adapter state
      var adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        throw Exception("Please turn on Bluetooth");
      }

      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
        _devices =
            results.where((r) => r.device.platformName.isNotEmpty).toList();
        notifyListeners();
      });

      // Wait for scan to complete
      await Future.delayed(const Duration(seconds: 15));
      await FlutterBluePlus.stopScan();

      _isScanning = false;
      notifyListeners();
    } catch (e) {
      _isScanning = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Stop scanning
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  // Select a device
  void selectDevice(ScanResult device) {
    _selectedDevice = device;
    notifyListeners();
  }

  // Clear device selection
  void clearSelection() {
    _selectedDevice = null;
    notifyListeners();
  }

  // Send transaction via BLE
  Future<bool> sendTransaction(TransactionData data) async {
    if (_selectedDevice == null) {
      _errorMessage = "No device selected";
      return false;
    }

    try {
      _transferStatus = TransferStatus.sending;
      notifyListeners();

      // Connect to device
      await _selectedDevice!.device.connect(
        timeout: const Duration(seconds: 15),
        license: License.free,
      );

      // Discover services
      List<BluetoothService> services =
          await _selectedDevice!.device.discoverServices();

      // Find your custom service and characteristic
      // Replace with your actual UUIDs
      const String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
      const String characteristicUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

      BluetoothService? targetService;
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() ==
            serviceUUID.toLowerCase()) {
          targetService = service;
          break;
        }
      }

      if (targetService == null) {
        throw Exception("Transaction service not found");
      }

      // Find characteristic
      BluetoothCharacteristic? targetCharacteristic;
      for (var characteristic in targetService.characteristics) {
        if (characteristic.uuid.toString().toLowerCase() ==
            characteristicUUID.toLowerCase()) {
          targetCharacteristic = characteristic;
          break;
        }
      }

      if (targetCharacteristic == null) {
        throw Exception("Transaction characteristic not found");
      }

      // Prepare transaction data
      Map<String, dynamic> transactionJson = {
        'amount': data.amount,
        'description': data.description,
        'category': data.category,
        'timestamp': DateTime.now().toIso8601String(),
      };

      String jsonString = jsonEncode(transactionJson);
      List<int> bytes = utf8.encode(jsonString);

      // Write data to characteristic
      await targetCharacteristic.write(bytes);

      // Disconnect
      await _selectedDevice!.device.disconnect();

      _transferStatus = TransferStatus.success;
      notifyListeners();

      // Reset after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      _transferStatus = TransferStatus.idle;
      notifyListeners();

      return true;
    } catch (e) {
      _transferStatus = TransferStatus.error;
      _errorMessage = e.toString();
      notifyListeners();

      // Reset after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      _transferStatus = TransferStatus.idle;
      notifyListeners();

      return false;
    }
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }
}

enum TransferStatus {
  idle,
  sending,
  success,
  error,
}

class TransactionData {
  final double amount;
  final String description;
  final String category;

  TransactionData({
    required this.amount,
    required this.description,
    required this.category,
  });
}

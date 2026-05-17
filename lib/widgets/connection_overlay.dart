// lib/widgets/connection_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../services/bluetooth_service.dart';
import 'glass_card.dart';

class ConnectionOverlay extends StatelessWidget {
  final VoidCallback onConnected;
  const ConnectionOverlay({super.key, required this.onConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(160),
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.all(28),
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withAlpha(30),
                  border: Border.all(color: Colors.red.withAlpha(120), width: 2),
                ),
                child: const Icon(Icons.bluetooth_disabled,
                    color: Colors.redAccent, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Not Connected',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect to your HC-05/HC-06\nmodule to control the mower',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(160),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.bluetooth_searching),
                  label: const Text('Connect Device'),
                  onPressed: () =>
                      _showDevicePicker(context, onConnected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D7A3A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showDevicePicker(
    BuildContext context, VoidCallback onConnected) async {
  final btService = BluetoothService();
  List<BluetoothDevice> devices = [];

  try {
    devices = await btService.getPairedDevices();
  } catch (_) {}

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF0D1A0D),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _DevicePickerSheet(
      devices: devices,
      onConnected: onConnected,
    ),
  );
}

class _DevicePickerSheet extends StatefulWidget {
  final List<BluetoothDevice> devices;
  final VoidCallback onConnected;

  const _DevicePickerSheet(
      {required this.devices, required this.onConnected});

  @override
  State<_DevicePickerSheet> createState() => _DevicePickerSheetState();
}

class _DevicePickerSheetState extends State<_DevicePickerSheet> {
  String? _connectingAddress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paired Bluetooth Devices',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select your HC-05 / HC-06 module',
            style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (widget.devices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No paired devices found.\nPair HC-05/HC-06 in Bluetooth settings first.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...widget.devices.map((device) {
              final isConnecting =
                  _connectingAddress == device.address;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A3A1A),
                  ),
                  child: const Icon(Icons.bluetooth,
                      color: Color(0xFF4CAF50), size: 22),
                ),
                title: Text(
                  device.name ?? 'Unknown Device',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  device.address,
                  style: TextStyle(
                      color: Colors.white.withAlpha(120), fontSize: 12),
                ),
                trailing: isConnecting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF4CAF50),
                        ),
                      )
                    : const Icon(Icons.arrow_forward_ios,
                        color: Color(0xFF4CAF50), size: 16),
                onTap: isConnecting
                    ? null
                    : () async {
                        setState(
                            () => _connectingAddress = device.address);
                        final success =
                            await BluetoothService().connect(device);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        if (success) {
                          widget.onConnected();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '✓ Connected to ${device.name ?? device.address}'),
                              backgroundColor: const Color(0xFF2D7A3A),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  '✗ Connection failed. Check the device.'),
                              backgroundColor: Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
              );
            }),
        ],
      ),
    );
  }
}

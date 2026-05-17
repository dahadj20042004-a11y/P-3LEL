// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../services/settings_service.dart';
import '../widgets/grass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/direction_button.dart';
import '../widgets/distance_gauge.dart';
import '../widgets/connection_overlay.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bt = BluetoothService();
  late AppSettings _settings;
  bool _settingsLoaded = false;

  bool _isConnected = false;
  bool _cutterOn = false;
  double? _distance;

  StreamSubscription? _connSub;
  StreamSubscription? _dataSub;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    _connSub = _bt.connectionStream.listen((connected) {
      if (mounted) setState(() => _isConnected = connected);
    });

    _dataSub = _bt.dataStream.listen(_parseData);
  }

  Future<void> _loadSettings() async {
    _settings = await SettingsService.load();
    if (mounted) setState(() => _settingsLoaded = true);
  }

  void _parseData(String data) {
    // Arduino sends distance as "D:42.5\n" format
    if (data.startsWith('D:')) {
      final val = double.tryParse(data.substring(2));
      if (val != null && mounted) setState(() => _distance = val);
    }
  }

  void _sendCmd(String cmd) => _bt.sendCommand(cmd);
  void _sendStop() => _bt.sendCommand(_settings.cmdStop);

  void _toggleCutter() {
    setState(() => _cutterOn = !_cutterOn);
    _sendCmd(_cutterOn ? _settings.cmdCutterOn : _settings.cmdCutterOff);
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push<AppSettings>(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(settings: _settings),
      ),
    );
    if (result != null && mounted) {
      setState(() => _settings = result);
    }
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _dataSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_settingsLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A1A0A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: GrassBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Main UI
              Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        children: [
                          _buildStatusCard(),
                          const SizedBox(height: 12),
                          _buildDistanceCard(),
                          const SizedBox(height: 12),
                          _buildControlPad(),
                          const SizedBox(height: 12),
                          _buildCutterCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Disconnected overlay
              if (!_isConnected)
                ConnectionOverlay(
                  onConnected: () {
                    if (mounted) setState(() => _isConnected = true);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Left logo placeholder
          _buildLogoSlot('logo_left', 'assets/images/logo_faculty.png'),
          const Spacer(),

          // App title + version
          Column(
            children: [
              const Text(
                'LAWN MOWER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              Text(
                'CONTROLLER',
                style: TextStyle(
                  color: const Color(0xFF4CAF50),
                  fontSize: 11,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Right logo placeholder
          _buildLogoSlot('logo_right', 'assets/images/logo_university.png'),
        ],
      ),
    );
  }

  /// Builds a logo slot. Tries to load asset, falls back to placeholder.
  Widget _buildLogoSlot(String key, String assetPath) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xAA1A2E1A),
        border:
            Border.all(color: const Color(0x554CAF50), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, color: Color(0xFF4CAF50), size: 18),
              const SizedBox(height: 2),
              Text(
                key == 'logo_left' ? 'FACULTY' : 'UNIV',
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isConnected
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE53935),
              boxShadow: [
                BoxShadow(
                  color: (_isConnected
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935))
                      .withAlpha(120),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _isConnected ? 'CONNECTED' : 'DISCONNECTED',
            style: TextStyle(
              color: _isConnected
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE57373),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          // Connect/Disconnect button
          if (!_isConnected)
            GestureDetector(
              onTap: () => _showDevicePickerFromBar(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D7A3A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bluetooth, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Connect',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () async {
                await _bt.disconnect();
                if (mounted) setState(() => _isConnected = false);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xAA3A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: const Color(0x55E53935), width: 1),
                ),
                child: const Text(
                  'Disconnect',
                  style: TextStyle(
                      color: Color(0xFFE57373),
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          const SizedBox(width: 8),
          // Settings gear
          GestureDetector(
            onTap: _openSettings,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xAA1A2E1A),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: const Color(0x554CAF50), width: 1),
              ),
              child: const Icon(Icons.settings,
                  color: Color(0xFF4CAF50), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: DistanceGauge(
        distance: _distance,
        warningThreshold: _settings.warningDistance,
        dangerThreshold: _settings.dangerDistance,
      ),
    );
  }

  Widget _buildControlPad() {
    const btnSize = 76.0;
    const gap = 10.0;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'MOVEMENT CONTROL',
                style: TextStyle(
                  color: Color(0xFF90A490),
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // D-pad layout
          Column(
            children: [
              // Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DirectionButton(
                    icon: Icons.arrow_upward,
                    tooltip: 'Forward',
                    size: btnSize,
                    onPressed: () => _sendCmd(_settings.cmdForward),
                    onReleased: _sendStop,
                  ),
                ],
              ),
              const SizedBox(height: gap),
              // Left  Stop  Right
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DirectionButton(
                    icon: Icons.arrow_back,
                    tooltip: 'Left',
                    size: btnSize,
                    onPressed: () => _sendCmd(_settings.cmdLeft),
                    onReleased: _sendStop,
                  ),
                  const SizedBox(width: gap),
                  // Center stop button
                  GestureDetector(
                    onTap: _sendStop,
                    child: Container(
                      width: btnSize,
                      height: btnSize,
                      decoration: BoxDecoration(
                        color: const Color(0xAA2A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0x55E53935), width: 1.2),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stop_circle_outlined,
                              color: Color(0xFFE57373), size: 28),
                          SizedBox(height: 2),
                          Text('STOP',
                              style: TextStyle(
                                color: Color(0xFFE57373),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: gap),
                  DirectionButton(
                    icon: Icons.arrow_forward,
                    tooltip: 'Right',
                    size: btnSize,
                    onPressed: () => _sendCmd(_settings.cmdRight),
                    onReleased: _sendStop,
                  ),
                ],
              ),
              const SizedBox(height: gap),
              // Down
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DirectionButton(
                    icon: Icons.arrow_downward,
                    tooltip: 'Backward',
                    size: btnSize,
                    onPressed: () => _sendCmd(_settings.cmdBackward),
                    onReleased: _sendStop,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCutterCard() {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      borderColor: _cutterOn
          ? const Color(0xAA4CAF50)
          : const Color(0x554CAF50),
      child: Row(
        children: [
          // Icon animated when running
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _cutterOn
                  ? const Color(0x334CAF50)
                  : const Color(0x1A4CAF50),
              border: Border.all(
                color: _cutterOn
                    ? const Color(0xFF4CAF50)
                    : const Color(0x554CAF50),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.cut,
              color: _cutterOn
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF4CAF50).withAlpha(100),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BLADE CUTTER MOTOR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _cutterOn
                      ? '● Running  —  Blades spinning'
                      : '○ Stopped  —  Blades off',
                  style: TextStyle(
                    color: _cutterOn
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withAlpha(100),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Toggle switch
          GestureDetector(
            onTap: _isConnected ? _toggleCutter : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 34,
              decoration: BoxDecoration(
                color: _cutterOn
                    ? const Color(0xFF2D7A3A)
                    : const Color(0xFF1A1A2A),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: _cutterOn
                      ? const Color(0xFF4CAF50)
                      : const Color(0x554CAF50),
                  width: 1.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: _cutterOn
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _cutterOn
                            ? const Color(0xFF4CAF50)
                            : Colors.white.withAlpha(80),
                      ),
                      child: Icon(
                        _cutterOn ? Icons.power : Icons.power_off,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDevicePickerFromBar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1A0D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DevicePickerSheetInline(
        onConnected: () {
          if (mounted) setState(() => _isConnected = true);
        },
      ),
    );
  }
}

// Inline device picker for the status bar connect button
class _DevicePickerSheetInline extends StatefulWidget {
  final VoidCallback onConnected;
  const _DevicePickerSheetInline({required this.onConnected});

  @override
  State<_DevicePickerSheetInline> createState() =>
      _DevicePickerSheetInlineState();
}

class _DevicePickerSheetInlineState
    extends State<_DevicePickerSheetInline> {
  List<dynamic> _devices = [];
  bool _loading = true;
  String? _connectingAddr;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      _devices = await BluetoothService().getPairedDevices();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paired Bluetooth Devices',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            ))
          else if (_devices.isEmpty)
            const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No paired devices found.',
                  style: TextStyle(color: Colors.grey)),
            ))
          else
            ..._devices.map((device) {
              final isConn = _connectingAddr == device.address;
              return ListTile(
                leading: const Icon(Icons.bluetooth, color: Color(0xFF4CAF50)),
                title: Text(device.name ?? 'Unknown',
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(device.address,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
                trailing: isConn
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF4CAF50)))
                    : const Icon(Icons.arrow_forward_ios,
                        color: Color(0xFF4CAF50), size: 16),
                onTap: isConn
                    ? null
                    : () async {
                        setState(() => _connectingAddr = device.address);
                        final ok =
                            await BluetoothService().connect(device);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        if (ok) {
                          widget.onConnected();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '✓ Connected to ${device.name ?? device.address}'),
                            backgroundColor: const Color(0xFF2D7A3A),
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      },
              );
            }),
        ],
      ),
    );
  }
}

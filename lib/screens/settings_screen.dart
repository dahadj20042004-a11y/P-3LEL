// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../widgets/grass_background.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;
  const SettingsScreen({super.key, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _fwdCtrl;
  late TextEditingController _bwdCtrl;
  late TextEditingController _leftCtrl;
  late TextEditingController _rightCtrl;
  late TextEditingController _stopCtrl;
  late TextEditingController _cutOnCtrl;
  late TextEditingController _cutOffCtrl;
  late TextEditingController _dangerCtrl;
  late TextEditingController _warningCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.settings;
    _fwdCtrl = TextEditingController(text: s.cmdForward);
    _bwdCtrl = TextEditingController(text: s.cmdBackward);
    _leftCtrl = TextEditingController(text: s.cmdLeft);
    _rightCtrl = TextEditingController(text: s.cmdRight);
    _stopCtrl = TextEditingController(text: s.cmdStop);
    _cutOnCtrl = TextEditingController(text: s.cmdCutterOn);
    _cutOffCtrl = TextEditingController(text: s.cmdCutterOff);
    _dangerCtrl =
        TextEditingController(text: s.dangerDistance.toString());
    _warningCtrl =
        TextEditingController(text: s.warningDistance.toString());
  }

  @override
  void dispose() {
    for (final c in [
      _fwdCtrl, _bwdCtrl, _leftCtrl, _rightCtrl, _stopCtrl,
      _cutOnCtrl, _cutOffCtrl, _dangerCtrl, _warningCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final updated = AppSettings(
      cmdForward: _fwdCtrl.text.isNotEmpty ? _fwdCtrl.text : 'F',
      cmdBackward: _bwdCtrl.text.isNotEmpty ? _bwdCtrl.text : 'B',
      cmdLeft: _leftCtrl.text.isNotEmpty ? _leftCtrl.text : 'L',
      cmdRight: _rightCtrl.text.isNotEmpty ? _rightCtrl.text : 'R',
      cmdStop: _stopCtrl.text.isNotEmpty ? _stopCtrl.text : 'S',
      cmdCutterOn: _cutOnCtrl.text.isNotEmpty ? _cutOnCtrl.text : 'C',
      cmdCutterOff: _cutOffCtrl.text.isNotEmpty ? _cutOffCtrl.text : 'X',
      dangerDistance: int.tryParse(_dangerCtrl.text) ?? 20,
      warningDistance: int.tryParse(_warningCtrl.text) ?? 50,
    );
    await SettingsService.save(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ Settings saved successfully'),
          backgroundColor: const Color(0xFF2D7A3A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GrassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xAA1A2E1A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0x554CAF50), width: 1),
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white70, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.settings,
                        color: Color(0xFF4CAF50), size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Settings & Commands',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    children: [
                      _buildSection(
                        icon: Icons.navigation,
                        title: 'Movement Commands',
                        subtitle: 'Characters sent to Arduino for movement',
                        children: [
                          _buildCommandRow(
                              '↑ Forward', _fwdCtrl, Icons.arrow_upward),
                          _buildCommandRow(
                              '↓ Backward', _bwdCtrl, Icons.arrow_downward),
                          _buildCommandRow(
                              '← Left', _leftCtrl, Icons.arrow_back),
                          _buildCommandRow(
                              '→ Right', _rightCtrl, Icons.arrow_forward),
                          _buildCommandRow(
                              '■ Stop', _stopCtrl, Icons.stop),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        icon: Icons.cut,
                        title: 'Cutter Motor Commands',
                        subtitle: 'Characters to toggle blade motor',
                        children: [
                          _buildCommandRow(
                              'Cutter ON', _cutOnCtrl, Icons.power),
                          _buildCommandRow(
                              'Cutter OFF', _cutOffCtrl, Icons.power_off),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        icon: Icons.radar,
                        title: 'Distance Thresholds',
                        subtitle: 'Gauge color-change distances (cm)',
                        children: [
                          _buildThresholdRow(
                            '🔴 Danger Distance (cm)',
                            _dangerCtrl,
                            Colors.redAccent,
                            hint: '20',
                          ),
                          _buildThresholdRow(
                            '🟡 Warning Distance (cm)',
                            _warningCtrl,
                            const Color(0xFFFFB300),
                            hint: '50',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Save Settings',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D7A3A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF4CAF50), size: 18),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(120),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0x334CAF50), height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCommandRow(
      String label, TextEditingController ctrl, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4CAF50), size: 16),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: ctrl,
              maxLength: 3,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                counterText: '',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                filled: true,
                fillColor: const Color(0xFF0D1A0D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D5A2D)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D5A2D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdRow(
      String label, TextEditingController ctrl, Color accent,
      {String hint = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: accent.withAlpha(80)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                filled: true,
                fillColor: const Color(0xFF0D1A0D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accent.withAlpha(60)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accent.withAlpha(60)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accent, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

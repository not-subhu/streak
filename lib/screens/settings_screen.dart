import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../providers/accent_provider.dart';
import '../theme.dart';

// Preset accent colors
const _presets = [
  Color(0xFF7C3AED), // violet (default)
  Color(0xFF2563EB), // blue
  Color(0xFF059669), // emerald
  Color(0xFFD97706), // amber
  Color(0xFFDC2626), // red
  Color(0xFFDB2777), // pink
  Color(0xFF0891B2), // cyan
  Color(0xFF65A30D), // lime
  Color(0xFFEA580C), // orange
  Color(0xFF7C3AED).withRed(120), // indigo-ish
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showWheel = false;

  @override
  Widget build(BuildContext context) {
    final accentProvider = context.watch<AccentProvider>();
    final accent = accentProvider.accent;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 20),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary, letterSpacing: -0.5,
                ),
              ),
            ),

            // Section: Appearance
            _sectionLabel('Appearance'),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accent colour',
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Applied to the + button, tab highlights, streak labels, and check buttons.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),

                  // Preset swatches
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ..._presets.map((c) => _Swatch(
                        color: c,
                        selected: accent.value == c.value,
                        onTap: () {
                          accentProvider.setAccent(c);
                          setState(() => _showWheel = false);
                        },
                      )),
                      // Custom button
                      GestureDetector(
                        onTap: () => setState(() => _showWheel = !_showWheel),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _showWheel ? accent : AppTheme.border,
                              width: 2,
                            ),
                            gradient: const SweepGradient(colors: [
                              Colors.red, Colors.orange, Colors.yellow,
                              Colors.green, Colors.blue, Colors.purple, Colors.red,
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Color wheel (toggle)
                  if (_showWheel) ...[
                    const SizedBox(height: 16),
                    HueRingPicker(
                      pickerColor: accent,
                      onColorChanged: accentProvider.setAccent,
                      enableAlpha: false,
                      displayThumbColor: true,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Live preview
                  Row(
                    children: [
                      const Text(
                        'Preview',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                      const SizedBox(width: 12),
                      // FAB preview
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      // Check button preview
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.check, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      // Streak text preview
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '7',
                              style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: accent, fontFamily: 'monospace',
                              ),
                            ),
                            const TextSpan(
                              text: ' day streak',
                              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionLabel('About'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'App', value: 'streaks.'),
                  _divider(),
                  _InfoRow(label: 'Version', value: '1.0.0'),
                  _divider(),
                  _InfoRow(label: 'Storage', value: 'Local only, never synced'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 10, fontWeight: FontWeight.w600,
      color: AppTheme.textMuted, letterSpacing: 1.0,
    ),
  );

  Widget _divider() => const Divider(height: 1, color: AppTheme.border, indent: 16);
}

class _Swatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Swatch({required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: Colors.white, width: 2.5)
              : Border.all(color: Colors.transparent, width: 2.5),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
          Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

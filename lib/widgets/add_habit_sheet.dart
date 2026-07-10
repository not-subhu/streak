import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habits_provider.dart';
import '../theme.dart';

class AddHabitSheet extends StatefulWidget {
  final Habit? existing;
  const AddHabitSheet({super.key, this.existing});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  late TextEditingController _nameCtrl;
  late String _icon;
  late Color _color;

  bool _showEmojiPicker = false;
  bool _showColorPicker = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _icon = widget.existing?.icon ?? '🎯';
    _color = widget.existing != null
        ? Color(widget.existing!.color)
        : const Color(0xFF7C3AED);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.muted2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            isEditing ? 'Edit habit' : 'New habit',
            style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Name field
          _label('Name'),
          const SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            autofocus: !isEditing,
            maxLength: 40,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g. Read for 20 min',
              hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
              counterText: '',
              filled: true,
              fillColor: AppTheme.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.accent),
              ),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 18),

          // Icon + Color row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Icon'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => setState(() {
                        _showEmojiPicker = !_showEmojiPicker;
                        _showColorPicker = false;
                      }),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _showEmojiPicker ? AppTheme.accent : AppTheme.border,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_icon, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 6),
                            const Icon(Icons.expand_more, color: AppTheme.textMuted, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Color'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => setState(() {
                        _showColorPicker = !_showColorPicker;
                        _showEmojiPicker = false;
                      }),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _showColorPicker ? AppTheme.accent : AppTheme.border,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 26, height: 26,
                              decoration: BoxDecoration(
                                color: _color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.expand_more, color: AppTheme.textMuted, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Emoji picker
          if (_showEmojiPicker) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: EmojiPicker(
                onEmojiSelected: (_, emoji) {
                  setState(() {
                    _icon = emoji.emoji;
                    _showEmojiPicker = false;
                  });
                },
                config: Config(
                  emojiViewConfig: EmojiViewConfig(
                    columns: 8,
                    emojiSizeMax: 28,
                    backgroundColor: AppTheme.surface2,
                    noRecents: const Text(
                      'No recents',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ),
                  categoryViewConfig: const CategoryViewConfig(
                    backgroundColor: AppTheme.surface2,
                    indicatorColor: AppTheme.accent,
                    iconColorSelected: AppTheme.accent,
                    iconColor: AppTheme.textMuted,
                    tabBarHeight: 44,
                  ),
                  bottomActionBarConfig: const BottomActionBarConfig(
                    backgroundColor: AppTheme.surface2,
                    buttonColor: AppTheme.accent,
                    buttonIconColor: Colors.white,
                  ),
                  searchViewConfig: const SearchViewConfig(
                    backgroundColor: AppTheme.surface2,
                    buttonIconColor: AppTheme.accent,
                  ),
                ),
              ),
            ),
          ],

          // Color wheel
          if (_showColorPicker) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface2,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: HueRingPicker(
                pickerColor: _color,
                onColorChanged: (c) => setState(() => _color = c),
                enableAlpha: false,
                displayThumbColor: true,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textMuted,
                    side: const BorderSide(color: AppTheme.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isEditing ? 'Save changes' : 'Add habit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final provider = context.read<HabitsProvider>();
    if (widget.existing != null) {
      provider.updateHabit(
        widget.existing!.id,
        name: name,
        icon: _icon,
        color: _color.value,
      );
    } else {
      provider.addHabit(name: name, icon: _icon, color: _color.value);
    }
    Navigator.pop(context);
  }

  Widget _label(String text) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 10, fontWeight: FontWeight.w600,
      color: AppTheme.textMuted, letterSpacing: 0.8,
    ),
  );
}

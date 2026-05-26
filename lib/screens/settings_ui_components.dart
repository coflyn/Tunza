// ignore_for_file: library_private_types_in_public_api, deprecated_member_use
part of 'settings_screen.dart';

extension SettingsUIComponents on _SettingsScreenState {
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(
          color: _activeAccentColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPremiumCard({required List<Widget> children}) {
    final isLight = _selectedThemeMode == 'light';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: isLight
            ? Border.all(color: Colors.black.withOpacity(0.05))
            : null,
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final int idx = entry.key;
          final Widget child = entry.value;
          if (idx == children.length - 1) return child;
          return Column(
            children: [
              child,
              Divider(
                height: 1,
                thickness: 1,
                color: isLight
                    ? Colors.black.withOpacity(0.04)
                    : Colors.white.withOpacity(0.04),
                indent: 56,
                endIndent: 16,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPremiumListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
    bool isActive = false,
  }) {
    final isLight = _selectedThemeMode == 'light';
    final effectiveIconColor =
        iconColor ??
        (isActive
            ? _activeAccentColor
            : (isLight ? Colors.black54 : Colors.white70));
    final effectiveTitleColor =
        titleColor ?? (isLight ? const Color(0xFF1A1A1A) : Colors.white);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: effectiveIconColor.withOpacity(isLight ? 0.06 : 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: effectiveIconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: effectiveTitleColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isActive
                    ? effectiveIconColor.withOpacity(0.8)
                    : (isLight ? Colors.black45 : Colors.white38),
                fontSize: 12,
              ),
            )
          : null,
      trailing: trailing,
    );
  }

  Widget _buildPremiumSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildPremiumListTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      isActive: value,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: _activeAccentColor,
        inactiveThumbColor: Colors.white54,
        inactiveTrackColor: Colors.white10,
      ),
    );
  }
}

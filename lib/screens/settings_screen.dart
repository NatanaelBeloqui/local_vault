import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onDarkModeChanged;

  const SettingsScreen({super.key, required this.onDarkModeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _service = SettingsService();

  bool _darkMode = false;
  String _language = 'Português';
  bool _notifications = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final darkMode = await _service.getDarkMode();
    final language = await _service.getLanguage();
    final notifications = await _service.getNotifications();
    setState(() {
      _darkMode = darkMode;
      _language = language;
      _notifications = notifications;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(title: 'Aparência'),
        _SettingsTile(
          icon: Icons.dark_mode_outlined,
          title: 'Modo Escuro',
          subtitle: 'Altera o tema do aplicativo',
          trailing: Switch(
            value: _darkMode,
            onChanged: (value) async {
              await _service.setDarkMode(value);
              setState(() => _darkMode = value);
              widget.onDarkModeChanged(value);
            },
          ),
        ),
        const SizedBox(height: 8),
        _SectionHeader(title: 'Localização'),
        _SettingsTile(
          icon: Icons.language_outlined,
          title: 'Idioma',
          subtitle: _language,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguagePicker(),
        ),
        const SizedBox(height: 8),
        _SectionHeader(title: 'Notificações'),
        _SettingsTile(
          icon: Icons.notifications_outlined,
          title: 'Notificações',
          subtitle: 'Receber alertas do aplicativo',
          trailing: Switch(
            value: _notifications,
            onChanged: (value) async {
              await _service.setNotifications(value);
              setState(() => _notifications = value);
            },
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Preferências salvas com SharedPreferences — persistem entre sessões.',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Selecionar Idioma',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              for (final lang in ['Português', 'English'])
                ListTile(
                  title: Text(lang),
                  trailing: _language == lang
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () async {
                    await _service.setLanguage(lang);
                    setState(() => _language = lang);
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

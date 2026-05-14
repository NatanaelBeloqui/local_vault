import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/user_profile.dart';

class MigrationService {
  static const _keyAppVersion = 'app_data_version';
  static const _currentVersion = 2;

  /// Verifica se há dados legados e executa a migração necessária.
  Future<void> runMigrationIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt(_keyAppVersion) ?? 1;

    if (savedVersion < _currentVersion) {
      await _migrateFromV1ToV2(prefs);
      await prefs.setInt(_keyAppVersion, _currentVersion);
      print('[MigrationService] Migração v$savedVersion → v$_currentVersion concluída.');
    } else {
      print('[MigrationService] Dados já na versão $_currentVersion. Nenhuma migração necessária.');
    }
  }

  /// Migra dados salvos no formato v1 (chaves antigas) para o formato v2 (Hive).
  Future<void> _migrateFromV1ToV2(SharedPreferences prefs) async {
    // Chaves antigas usadas na v1
    final oldName = prefs.getString('user_name');
    final oldEmail = prefs.getString('user_email');

    if (oldName != null || oldEmail != null) {
      final box = await Hive.openBox<UserProfile>('profiles');

      // Só migra se ainda não existir perfil no Hive
      if (box.isEmpty) {
        final profile = UserProfile(
          name: oldName ?? 'Usuário Migrado',
          email: oldEmail ?? 'sem-email@local.com',
          registrationDate: DateTime.now().toIso8601String().substring(0, 10),
          score: 0,
        );
        await box.add(profile);
      }

      // Remove chaves antigas
      await prefs.remove('user_name');
      await prefs.remove('user_email');

      print('[MigrationService] Perfil legado migrado para Hive com sucesso.');
    }
  }

  Future<int> getCurrentVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAppVersion) ?? 1;
  }

  /// Simula dados da v1 para fins de demonstração
  Future<void> seedLegacyData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAppVersion, 1);
    await prefs.setString('user_name', 'Ana Silva (legado)');
    await prefs.setString('user_email', 'ana.legado@email.com');
    print('[MigrationService] Dados legados v1 inseridos para demonstração.');
  }
}

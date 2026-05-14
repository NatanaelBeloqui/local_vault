import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _scoreController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late Box<UserProfile> _box;
  bool _boxReady = false;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _box = await Hive.openBox<UserProfile>('profiles');
    setState(() => _boxReady = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      registrationDate: DateTime.now().toIso8601String().substring(0, 10),
      score: int.tryParse(_scoreController.text) ?? 0,
    );

    await _box.clear();
    await _box.add(profile);

    _nameController.clear();
    _emailController.clear();
    _scoreController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil salvo com sucesso!')),
      );
    }
  }

  Future<void> _clearProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Perfil'),
        content: const Text(
          'Isso remove todos os seus dados (direito ao esquecimento — LGPD). Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _box.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil excluído.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_boxReady) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Perfil salvo
        ValueListenableBuilder(
          valueListenable: _box.listenable(),
          builder: (context, Box<UserProfile> box, _) {
            if (box.isEmpty) {
              return _EmptyProfile();
            }
            final profile = box.getAt(0)!;
            return _ProfileCard(profile: profile, onDelete: _clearProfile);
          },
        ),
        const SizedBox(height: 24),

        // Formulário
        Text(
          'SALVAR PERFIL',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Informe o e-mail' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _scoreController,
                    decoration: const InputDecoration(
                      labelText: 'Pontuação',
                      prefixIcon: Icon(Icons.star_outline),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Informe a pontuação' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar no Hive'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.storage_outlined, color: Colors.orange[700], size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dados armazenados com Hive + TypeAdapter — NoSQL local de alto desempenho.',
                  style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.person_off_outlined,
              size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 8),
          Text('Nenhum perfil salvo',
              style: TextStyle(color: Theme.of(context).colorScheme.outline)),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onDelete;

  const _ProfileCard({required this.profile, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PERFIL SALVO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    )),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Excluir (LGPD)',
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.person_outline, label: profile.name),
            _InfoRow(icon: Icons.email_outlined, label: profile.email),
            _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Cadastro: ${profile.registrationDate}'),
            _InfoRow(
                icon: Icons.star_outline,
                label: 'Pontuação: ${profile.score}'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onPrimaryContainer)),
          ),
        ],
      ),
    );
  }
}

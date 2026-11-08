import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _favoriteController = TextEditingController(); // Latihan 3
  bool _controllersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllersInitialized) return;

    final provider = UserProvider.of(context);
    _nameController = TextEditingController(text: provider.user.name);
    _emailController = TextEditingController(text: provider.user.email);
    _controllersInitialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = UserProvider.of(context);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    // Latihan 5 (b): cek karakter berbahaya pada nama (mis. <script>)
    final dangerous = RegExp(r'[<>]|javascript:', caseSensitive: false);
    if (dangerous.hasMatch(name)) {
      _showError('Nama mengandung karakter berbahaya (<, >, javascript:)');
      return;
    }

    // Latihan 5 (a): cek email sudah digunakan (simulasi via SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    final registered = prefs.getStringList('registered_emails') ?? [];
    final currentEmail = (prefs.getString('user_email') ?? '').toLowerCase();
    final newEmail = email.toLowerCase();

    if (registered.contains(newEmail) && newEmail != currentEmail) {
      if (!mounted) return;
      _showError('Email sudah digunakan oleh akun lain');
      return;
    }

    if (!registered.contains(newEmail)) {
      await prefs.setStringList('registered_emails', [...registered, newEmail]);
    }

    final updatedUser = provider.user.copyWith(
      name: name,
      email: email,
      isLoggedIn: true,
    );
    await provider.updateUser(updatedUser);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              UserProvider.of(context).logout();
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Latihan 3: tambah favorit dari input
  void _addFavorite() {
    final provider = UserProvider.of(context);
    provider.addFavorite(_favoriteController.text);
    _favoriteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = UserProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (provider.user.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurple,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Profil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Latihan 3: daftar favorit
                      const Text(
                        'Daftar Favorit (Hobi)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _favoriteController,
                              label: 'Tambah favorit',
                              icon: Icons.favorite,
                              onFieldSubmitted: (_) => _addFavorite(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _addFavorite,
                            icon: const Icon(Icons.add),
                            tooltip: 'Tambah',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (provider.favorites.isEmpty)
                        const Text(
                          'Belum ada favorit',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          children: provider.favorites
                              .map(
                                (item) => Chip(
                                  label: Text(item),
                                  onDeleted: () =>
                                      provider.removeFavorite(item),
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: 16),

                      Card(
                        color: Colors.amber.withValues(alpha: 0.15),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info, color: Colors.amber[800]),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Catatan Keamanan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Data disimpan di SharedPreferences (plaintext). '
                                'Jangan simpan password atau data sensitif di sini. '
                                'Gunakan secure storage untuk data sensitif.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

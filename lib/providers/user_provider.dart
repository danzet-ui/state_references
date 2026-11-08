import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider extends InheritedWidget {
  final User user;
  final Function(User) updateUser;
  final VoidCallback logout;
  final bool isLoading;

  // Latihan 1: preferensi tema
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  // Latihan 2: counter kunjungan
  final int visitCount;

  // Latihan 3: daftar favorit
  final List<String> favorites;
  final void Function(String) addFavorite;
  final void Function(String) removeFavorite;

  const UserProvider({
    super.key,
    required this.user,
    required this.updateUser,
    required this.logout,
    required this.isLoading,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.visitCount,
    required this.favorites,
    required this.addFavorite,
    required this.removeFavorite,
    required super.child,
  });

  static UserProvider of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<UserProvider>();
    assert(provider != null, 'UserProvider tidak ditemukan di context');
    return provider!;
  }

  @override
  bool updateShouldNotify(UserProvider oldWidget) {
    return oldWidget.user != user ||
        oldWidget.isLoading != isLoading ||
        oldWidget.isDarkMode != isDarkMode ||
        oldWidget.visitCount != visitCount ||
        oldWidget.favorites != favorites;
  }
}

// StatefulWidget yang membungkus InheritedWidget
class UserProviderWrapper extends StatefulWidget {
  final Widget child;

  const UserProviderWrapper({super.key, required this.child});

  @override
  State<UserProviderWrapper> createState() => _UserProviderWrapperState();
}

class _UserProviderWrapperState extends State<UserProviderWrapper> {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Memuat data user dari SharedPreferences
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // Latihan 1: muat preferensi tema
    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;

    // Latihan 2: increment counter setiap aplikasi dibuka
    final visitCount = (prefs.getInt('visit_count') ?? 0) + 1;
    await prefs.setInt('visit_count', visitCount);

    // Latihan 3: muat daftar favorit
    final favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      _user = User(
        name: name,
        email: email,
        isLoggedIn: isLoggedIn,
      );
      _isDarkMode = isDarkMode;
      _visitCount = visitCount;
      _favorites = favorites;
      _isLoading = false;
    });
  }

  // Menyimpan data user ke SharedPreferences
  Future<void> _updateUser(User newUser) async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setBool('is_logged_in', newUser.isLoggedIn);

    setState(() {
      _user = newUser;
      _isLoading = false;
    });
  }

  // Logout: hapus data user (kecuali email)
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);

    setState(() {
      _user = _user.copyWith(name: '', isLoggedIn: false);
    });
  }

  // Latihan 1: ganti tema Light/Dark lalu simpan
  Future<void> _toggleTheme() async {
    final newValue = !_isDarkMode;
    setState(() {
      _isDarkMode = newValue;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', newValue);
  }

  // Latihan 3: tambah favorit
  Future<void> _addFavorite(String item) async {
    final value = item.trim();
    if (value.isEmpty || _favorites.contains(value)) return;

    final newList = [..._favorites, value];
    setState(() {
      _favorites = newList;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', newList);
  }

  // Latihan 3: hapus favorit
  Future<void> _removeFavorite(String item) async {
    final newList = _favorites.where((e) => e != item).toList();
    setState(() {
      _favorites = newList;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', newList);
  }

  @override
  Widget build(BuildContext context) {
    return UserProvider(
      user: _user,
      updateUser: _updateUser,
      logout: _logout,
      isLoading: _isLoading,
      isDarkMode: _isDarkMode,
      toggleTheme: _toggleTheme,
      visitCount: _visitCount,
      favorites: _favorites,
      addFavorite: _addFavorite,
      removeFavorite: _removeFavorite,
      child: widget.child,
    );
  }
}

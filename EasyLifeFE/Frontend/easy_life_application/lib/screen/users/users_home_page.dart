import 'package:easy_life_application/screen/users/users_detail_page.dart';
import 'package:easy_life_application/screen/users/user_create_page.dart'; // 👈 IMPORT CREATE PAGE
import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/users_model.dart';
import 'package:easy_life_application/services/users/users_service.dart';

class UsersHomePage extends StatefulWidget {
  const UsersHomePage({super.key});

  @override
  State<UsersHomePage> createState() => _UsersHomePageState();
}

class _UsersHomePageState extends State<UsersHomePage> {
  final UsersService _usersService = UsersService();
  final TextEditingController _searchController = TextEditingController();

  List<UsersModel> _allUsers = [];
  List<UsersModel> _filteredUsers = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _usersService.getAllUsers();
      if (!mounted) return;
      setState(() {
        _allUsers = users;
        _applyFilter(_searchController.text);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers.where((u) {
        final fullName = '${u.firstName} ${u.surname}'.toLowerCase();
        return fullName.contains(q);
      }).toList();
    }
    setState(() {});
  }

  String _userInitials(UsersModel u) {
    final f = u.firstName.isNotEmpty ? u.firstName[0] : '';
    final s = u.surname.isNotEmpty ? u.surname[0] : '';
    return (f + s).toUpperCase();
  }

  // 👇 handler per il tasto Add Profile
  Future<void> _onAddProfilePressed() async {
    final created = await Navigator.of(context).push<UsersModel?>(
      MaterialPageRoute(builder: (_) => const UserCreatePage()),
    );

    if (created != null) {
      // aggiorno lista locale senza ricaricare tutto
      setState(() {
        _allUsers.insert(0, created);
        _applyFilter(_searchController.text);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profilo utente creato.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = media.size.width > 700 ? 600.0 : double.infinity;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Users'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: Pallete.mainBackgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(context),
                  const SizedBox(height: 12),
                  _buildSearchBar(context),
                  const SizedBox(height: 8),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: _buildBody(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addProfile',
        onPressed: _onAddProfilePressed,
        icon: const Icon(Icons.person_add),
        label: const Text('Add profile'),
        backgroundColor: Pallete.accentBlue,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Utenti',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gestisci gli utenti collegati ai tuoi acquisti.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _applyFilter,
        decoration: InputDecoration(
          hintText: 'Cerca per nome o cognome...',
          filled: true,
          fillColor: Colors.black.withOpacity(0.25),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Pallete.accentBlue, width: 1.6),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Errore: $_error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Text(
          'Nessun utente trovato.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _filteredUsers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserCard(context, user);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UsersModel user) {
    final initials = _userInitials(user);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => UserDetailPage(user: user)));
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Pallete.accentBlue.withOpacity(0.25),
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName} ${user.surname}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.purchaseNumber} acquisti',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}

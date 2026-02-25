import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/data/models/users/user_model.dart';
import 'package:vertecx/data/services/user_service.dart'; 
import 'package:vertecx/presentation/widgets/usersWidgets/user_card_widget.dart';
import 'package:vertecx/presentation/widgets/components/search/search.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/data/repositories/userRepositories/bloc/user_bloc.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {
  late final UserBloc _bloc;
  int _usersToShow = 4;
  String _searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  List<String> _permissions = const <String>[];

  @override
  void initState() {
    super.initState();
    _bloc = UserBloc(UserService())..add(LoadUsers());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List<String>) {
      _permissions = args;
      SessionContext.permissions = args;
      return;
    }
    _permissions = SessionContext.permissions;
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _loadMoreUsers(int totalUsers) {
    setState(() {
      _usersToShow = (_usersToShow + 2).clamp(0, totalUsers);
    });
  }

  void reloadUsers() {
    _bloc.add(LoadUsers());
  }

  String? _firstAdminId(List<UserModel> users) {
    String? adminId;
    int? minId;
    for (final user in users) {
      if (user.roleString.toLowerCase() != 'admin') continue;
      final parsedId = int.tryParse(user.id);
      if (parsedId == null) continue;
      if (minId == null || parsedId < minId) {
        minId = parsedId;
        adminId = user.id;
      }
    }
    return adminId;
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<UserBloc, UserState>(
        listenWhen: (previous, current) {
          return previous is UserLoaded && current is UserLoaded;
        },
        listener: (context, state) {
        },
        child: Scaffold(
          appBar: const AppTopBar(title: 'Usuarios', showMenu: true),
          drawer: Drawer(
            backgroundColor: Colors.transparent,
            child: SideMenuPanel(
              permissions: _permissions,
              onClose: () => Navigator.of(context).maybePop(),
              onLogout: () {
                Navigator.of(context).maybePop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              },
            ),
          ),
          backgroundColor: const Color(0xFFE8E8E8),
          body: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              // Estado de carga
              if (state is UserLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Estado de error
              if (state is UserError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              // Estado cargado
              if (state is UserLoaded) {
                final filteredUsers = state.users
                    .where((u) => u.matchesQuery(_searchQuery))
                    .toList();
                final protectedAdminId = _firstAdminId(state.users);

                final users = filteredUsers.take(_usersToShow).toList();
                final allUsersLoaded = _usersToShow >= filteredUsers.length;

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Buscar(
                          hintText: "Buscar usuario...",
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                        ),
                        const SizedBox(height: 20),
                        ...users.map(
                          (user) => UserCardWidget(
                            user: user,
                            onToggleStatus:
                                (protectedAdminId != null && user.id == protectedAdminId)
                                    ? null
                                    : () {
                                        context.read<UserBloc>().add(
                                              ToggleUserStatus(user.id),
                                            );
                                      },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // BotÃ³n para cargar mÃ¡s
                        if (filteredUsers.isNotEmpty)
                          if (!allUsersLoaded)
                            TextButton(
                              onPressed: () =>
                                  _loadMoreUsers(filteredUsers.length),
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/icons/Vector.png",
                                    width: 20,
                                    height: 20,
                                  ),
                                  const Text(
                                    "Cargar mÃ¡s Usuarios",
                                    style: TextStyle(color: Color(0xFFB20000)),
                                  ),
                                ],
                              ),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Ya estÃ¡n todos los usuarios",
                                style: TextStyle(
                                  color: Color(0xFFB20000),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "No se encontraron usuarios",
                              style: TextStyle(
                                color: Color(0xFFB20000),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              }

              // Estado inicial (seguro)
              return const Center(child: CircularProgressIndicator());
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _scrollToTop,
            backgroundColor: const Color(0xFFB20000),
            child: const Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

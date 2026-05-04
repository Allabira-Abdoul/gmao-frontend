import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Infrastructure (Adapters)
import 'package:frontend/infrastructure/repositories/in_memory_counter_repository.dart';
import 'package:frontend/infrastructure/repositories/http_auth_repository.dart';
import 'package:frontend/infrastructure/repositories/http_user_repository.dart';
import 'package:frontend/infrastructure/repositories/http_role_repository.dart';

// Application (Use Cases)
import 'package:frontend/application/usecases/get_counter_usecase.dart';
import 'package:frontend/application/usecases/increment_counter_usecase.dart';
import 'package:frontend/application/usecases/login_usecase.dart';
import 'package:frontend/application/usecases/user_management_usecases.dart';

// Presentation
import 'package:frontend/presentation/state/counter_state.dart';
import 'package:frontend/presentation/state/auth_state.dart';
import 'package:frontend/presentation/state/user_management_state.dart';
import 'package:frontend/presentation/pages/login_page.dart';
import 'package:frontend/presentation/pages/technicien_dashboard.dart';
import 'package:frontend/presentation/pages/manager_dashboard.dart';
import 'package:frontend/presentation/pages/admin_dashboard.dart';
import 'package:frontend/presentation/pages/unauthorized_platform_page.dart';
import 'package:frontend/presentation/pages/user_management_page.dart';
import 'package:frontend/presentation/pages/profile_page.dart';
import 'package:frontend/presentation/widgets/auth_guard.dart';

void main() async {
  // Initialize Flutter first to allow us to run context.read
  WidgetsFlutterBinding.ensureInitialized();

  // Infrastructure
  final counterRepository = InMemoryCounterRepository();
  final authRepository = HttpAuthRepository();
  final userRepository = HttpUserRepository();
  final roleRepository = HttpRoleRepository();

  // Application
  final getCounterUseCase = GetCounterUseCase(counterRepository);
  final incrementCounterUseCase = IncrementCounterUseCase(counterRepository);
  final loginUseCase = LoginUseCase(authRepository);
  
  final getUsersUseCase = GetUsersUseCase(userRepository);
  final createUserUseCase = CreateUserUseCase(userRepository);
  final updateUserUseCase = UpdateUserUseCase(userRepository);
  final deleteUserUseCase = DeleteUserUseCase(userRepository);
  final getRolesUseCase = GetRolesUseCase(roleRepository);

  final authState = AuthState(loginUseCase: loginUseCase);
  await authState.checkAuth();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CounterState(
            getCounterUseCase: getCounterUseCase,
            incrementCounterUseCase: incrementCounterUseCase,
          ),
        ),
        ChangeNotifierProvider.value(
          value: authState,
        ),
        Provider.value(
          value: GetCurrentUserUseCase(userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => UserManagementState(
            getUsersUseCase: getUsersUseCase,
            createUserUseCase: createUserUseCase,
            updateUserUseCase: updateUserUseCase,
            deleteUserUseCase: deleteUserUseCase,
            getRolesUseCase: getRolesUseCase,
            authState: authState,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, authState, child) {
        String initialRoute = '/login';
        if (authState.status == AuthStatus.authenticated) {
           final redirectPath = authState.getPlatformRedirect();
           if (redirectPath != null) {
              initialRoute = redirectPath;
           }
        }

        return MaterialApp(
          title: 'GMAO Premium',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF764BA2),
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.interTextTheme(),
            useMaterial3: true,
          ),
          initialRoute: initialRoute,
          routes: {
            '/login': (context) => const LoginPage(),
            '/profile': (context) => const ProfilePage(),
            '/technicien-dashboard': (context) => const AuthGuard(
              allowedRoles: ['Technicien'],
              child: TechnicienDashboard(),
            ),
            '/manager-dashboard': (context) => const AuthGuard(
              allowedRoles: ['Manager'],
              child: ManagerDashboard(),
            ),
            '/admin-dashboard': (context) => const AuthGuard(
              allowedRoles: ['Administrateur'],
              child: AdminDashboard(),
            ),
            '/admin/users': (context) => const AuthGuard(
              allowedRoles: ['Administrateur'],
              child: UserManagementPage(),
            ),
            '/unauthorized-platform': (context) => const UnauthorizedPlatformPage(),
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Infrastructure (Adapters)
import 'package:frontend/infrastructure/repositories/in_memory_counter_repository.dart';
import 'package:frontend/infrastructure/repositories/http_auth_repository.dart';

// Application (Use Cases)
import 'package:frontend/application/usecases/get_counter_usecase.dart';
import 'package:frontend/application/usecases/increment_counter_usecase.dart';
import 'package:frontend/application/usecases/login_usecase.dart';

// Presentation
import 'package:frontend/presentation/state/counter_state.dart';
import 'package:frontend/presentation/state/auth_state.dart';
import 'package:frontend/presentation/pages/login_page.dart';
import 'package:frontend/presentation/pages/technicien_dashboard.dart';
import 'package:frontend/presentation/pages/manager_dashboard.dart';
import 'package:frontend/presentation/pages/admin_dashboard.dart';
import 'package:frontend/presentation/pages/unauthorized_platform_page.dart';

void main() async {
  // Initialize Flutter first to allow us to run context.read
  WidgetsFlutterBinding.ensureInitialized();

  // Infrastructure
  final counterRepository = InMemoryCounterRepository();
  final authRepository = HttpAuthRepository();

  // Application
  final getCounterUseCase = GetCounterUseCase(counterRepository);
  final incrementCounterUseCase = IncrementCounterUseCase(counterRepository);
  final loginUseCase = LoginUseCase(authRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CounterState(
            getCounterUseCase: getCounterUseCase,
            incrementCounterUseCase: incrementCounterUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthState(loginUseCase: loginUseCase),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _protectedRoute(Widget child, List<String> allowedRoles) {
    return Consumer<AuthState>(
      builder: (context, authState, _) {
        if (authState.status != AuthStatus.authenticated ||
            authState.currentUser == null) {
          // Future microtask to avoid navigating during build phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!allowedRoles.contains(authState.currentUser!.role)) {
          return const UnauthorizedPlatformPage();
        }

        return child;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/technicien-dashboard': (context) =>
            _protectedRoute(const TechnicienDashboard(), ['Technicien']),
        '/manager-dashboard': (context) =>
            _protectedRoute(const ManagerDashboard(), ['Manager']),
        '/admin-dashboard': (context) =>
            _protectedRoute(const AdminDashboard(), ['Administrateur']),
        '/unauthorized-platform': (context) => const UnauthorizedPlatformPage(),
      },
    );
  }
}

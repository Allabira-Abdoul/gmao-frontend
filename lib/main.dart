import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http; // needed for http.Client()
import 'package:frontend/infrastructure/http/authenticated_client.dart';
import 'package:frontend/application/usecases/refresh_token_usecase.dart';

// Infrastructure (Adapters)
import 'package:frontend/infrastructure/repositories/in_memory_counter_repository.dart';
import 'package:frontend/infrastructure/repositories/http_auth_repository.dart';
import 'package:frontend/infrastructure/repositories/http_user_repository.dart';
import 'package:frontend/infrastructure/repositories/http_role_repository.dart';
import 'package:frontend/infrastructure/repositories/http_equipement_repository.dart';
import 'package:frontend/infrastructure/repositories/http_piece_rechange_repository.dart';

// Application (Use Cases)
import 'package:frontend/application/usecases/get_counter_usecase.dart';
import 'package:frontend/application/usecases/increment_counter_usecase.dart';
import 'package:frontend/application/usecases/login_usecase.dart';
import 'package:frontend/application/usecases/user_management_usecases.dart';
import 'package:frontend/application/usecases/equipement_usecases.dart';
import 'package:frontend/application/usecases/piece_rechange_usecases.dart';

// Presentation
import 'package:frontend/presentation/state/counter_state.dart';
import 'package:frontend/presentation/state/auth_state.dart';
import 'package:frontend/presentation/state/user_management_state.dart';
import 'package:frontend/presentation/state/equipement_state.dart';
import 'package:frontend/presentation/state/piece_rechange_state.dart';
import 'package:frontend/presentation/pages/login_page.dart';
import 'package:frontend/presentation/pages/technicien_dashboard.dart';
import 'package:frontend/presentation/pages/manager_dashboard.dart';
import 'package:frontend/presentation/pages/admin_dashboard.dart';
import 'package:frontend/presentation/pages/unauthorized_platform_page.dart';
import 'package:frontend/presentation/pages/user_management_page.dart';
import 'package:frontend/presentation/pages/profile_page.dart';
import 'package:frontend/presentation/pages/equipements_page.dart';
import 'package:frontend/presentation/pages/pieces_rechange_page.dart';
import 'package:frontend/presentation/widgets/auth_guard.dart';
import 'package:frontend/presentation/routes/app_router.dart';

void main() async {
  // Initialize Flutter first to allow us to run context.read
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Auth Infrastructure & Use Cases (doesn't need AuthenticatedClient)
  final authRepository = HttpAuthRepository();
  final loginUseCase = LoginUseCase(authRepository);
  final refreshTokenUseCase = RefreshTokenUseCase(authRepository);

  // 2. Auth State
  final authState = AuthState(
    loginUseCase: loginUseCase,
    refreshTokenUseCase: refreshTokenUseCase,
  );
  await authState.checkAuth();

  // 3. Authenticated Client
  final authenticatedClient = AuthenticatedClient(authState, http.Client());

  // 4. Other Infrastructure
  final counterRepository = InMemoryCounterRepository();
  final userRepository = HttpUserRepository(authenticatedClient);
  final roleRepository = HttpRoleRepository(authenticatedClient);
  final equipementRepository = HttpEquipementRepository(authenticatedClient);
  final pieceRechangeRepository = HttpPieceRechangeRepository(
    authenticatedClient,
  );

  // 5. Other Application Use Cases
  final getCounterUseCase = GetCounterUseCase(counterRepository);
  final incrementCounterUseCase = IncrementCounterUseCase(counterRepository);

  final getUsersUseCase = GetUsersUseCase(userRepository);
  final createUserUseCase = CreateUserUseCase(userRepository);
  final updateUserUseCase = UpdateUserUseCase(userRepository);
  final deleteUserUseCase = DeleteUserUseCase(userRepository);

  final getEquipementsUseCase = GetEquipementsUseCase(equipementRepository);
  final createEquipementUseCase = CreateEquipementUseCase(equipementRepository);
  final updateEquipementUseCase = UpdateEquipementUseCase(equipementRepository);
  final deleteEquipementUseCase = DeleteEquipementUseCase(equipementRepository);

  final getPiecesRechangeUseCase = GetPiecesRechangeUseCase(
    pieceRechangeRepository,
  );
  final createPieceRechangeUseCase = CreatePieceRechangeUseCase(
    pieceRechangeRepository,
  );
  final updatePieceRechangeUseCase = UpdatePieceRechangeUseCase(
    pieceRechangeRepository,
  );
  final deletePieceRechangeUseCase = DeletePieceRechangeUseCase(
    pieceRechangeRepository,
  );
  final getRolesUseCase = GetRolesUseCase(roleRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CounterState(
            getCounterUseCase: getCounterUseCase,
            incrementCounterUseCase: incrementCounterUseCase,
          ),
        ),
        ChangeNotifierProvider.value(value: authState),
        Provider.value(value: GetCurrentUserUseCase(userRepository)),
        ChangeNotifierProvider(
          create: (_) => UserManagementState(
            getUsersUseCase: getUsersUseCase,
            createUserUseCase: createUserUseCase,
            updateUserUseCase: updateUserUseCase,
            deleteUserUseCase: deleteUserUseCase,
            getRolesUseCase: getRolesUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EquipementState(
            getEquipementsUseCase: getEquipementsUseCase,
            createEquipementUseCase: createEquipementUseCase,
            updateEquipementUseCase: updateEquipementUseCase,
            deleteEquipementUseCase: deleteEquipementUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PieceRechangeState(
            getPiecesRechangeUseCase: getPiecesRechangeUseCase,
            createPieceRechangeUseCase: createPieceRechangeUseCase,
            updatePieceRechangeUseCase: updatePieceRechangeUseCase,
            deletePieceRechangeUseCase: deletePieceRechangeUseCase,
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
          final redirectPath = AppRouter.getPlatformRedirect(
            authState.currentUser,
          );
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
            '/profile': (context) => const AuthGuard(
              allowedRoles: ['Technicien', 'Manager', 'Administrateur'],
              child: ProfilePage(),
            ),
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
            '/equipements': (context) => const AuthGuard(
              allowedRoles: ['Administrateur', 'Manager', 'Technicien'],
              child: EquipementsPage(),
            ),
            '/pieces-rechange': (context) => const AuthGuard(
              allowedRoles: ['Administrateur', 'Manager', 'Technicien'],
              child: PiecesRechangePage(),
            ),
            '/unauthorized-platform': (context) =>
                const UnauthorizedPlatformPage(),
          },
        );
      },
    );
  }
}

import '../features/guide/app_tour_screen.dart';
import '../features/guide/guide_screen.dart';
import '../features/market/market_screen.dart';
import '../features/market/data/subscription_models.dart';
import '../features/market/product_screen.dart';
import '../features/market/recommendation_screen.dart';
import '../features/market/subscribe_screen.dart';
import '../features/market/subscription_detail_screen.dart';
import '../features/market/subscription_payment_screen.dart';
import '../features/bodybuilding/bodybuilding_screen.dart';
import '../features/bodybuilding/bb_session_screen.dart';
import '../features/devices/devices_screen.dart';
import 'package:go_router/go_router.dart';

import '../features/run/run_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/community/community_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/food/food_scan_screen.dart';
import '../features/home/home_shell.dart';
import '../features/home/main_screen.dart';
import '../features/launch/launch_screen.dart';
import '../features/nutrition/meal_detail_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/nutrition/nutrition_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/settings_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/resources/resource_detail_screen.dart';
import '../features/news/news_detail_screen.dart';
import '../features/news/news_screen.dart';
import '../features/search/search_screen.dart';
import '../features/setup/setup_screen.dart';
import '../features/support/support_screen.dart';
import '../features/workout/create_routine_screen.dart';
import '../features/workout/routine_detail_screen.dart';
import '../features/workout/workout_player_screen.dart';
import '../features/workout/workout_screen.dart';

abstract final class Routes {
  static const launch = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/auth/otp';
  static const setup = '/setup';
  static const home = '/home';
  static const shop = '/shop';
  static const resources = '/resources';
  static const favorites = '/favorites';
  static const support = '/support';
  static const subscription = '/subscription';
  static const recommendation = '/recommendation';
  static String subscribe(String planId) => '/subscribe/$planId';
  static const subscriptionPayment = '/subscribe/payment';
  static String mySubscription(String id) => '/my-subscription/$id';

  // 7. Top Menu — Home tab ichida, pastki menyu ko'rinib turadi.
  static const workout = '/home/workout';
  static const createRoutine = '/home/workout/create';
  static String routine(String id) => '/home/workout/routine/$id';
  static const progress = '/home/progress';
  static const nutrition = '/home/nutrition';
  static String meal(String id) => '/home/nutrition/meal/$id';
  static const community = '/home/community';

  /// To'liq ekran (pastki menyusiz).
  static String player(String id) => '/player/$id';
  static String resource(String id) => '/resource/$id';
  static String newsItem(String id) => '/news/$id';
  static const foodScan = '/food/scan';
  static const run = '/run';
  static const market = '/market';
  static const cart = '/market/cart';
  static String product(String id) => '/market/product/$id';
  static const bodybuilding = '/bb';
  static String bbSession(String program, int day) =>
      '/bb/session/$program/$day';

  // 6. Floating Menu
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const settings = '/profile/settings';
  static const devices = '/profile/devices';
  static const notifications = '/notifications';
  static const search = '/search';
  static const tour = '/tour';
  static const guide = '/guide';
}

/// Dev: `flutter run --dart-define=START_ROUTE=/recommendation` — shu ekrandan boshlash.
const _startRoute = String.fromEnvironment(
  'START_ROUTE',
  defaultValue: Routes.launch,
);

final appRouter = GoRouter(
  initialLocation: _startRoute,
  routes: [
    GoRoute(path: Routes.launch, builder: (_, _) => const LaunchScreen()),
    GoRoute(
      path: Routes.onboarding,
      builder: (_, _) => const OnboardingScreen(),
    ),
    GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
    GoRoute(path: Routes.signup, builder: (_, _) => const SignupScreen()),
    GoRoute(
      path: Routes.otp,
      builder: (_, s) => OtpScreen(args: s.extra! as OtpArgs),
    ),
    GoRoute(path: Routes.setup, builder: (_, _) => const SetupScreen()),
    GoRoute(
      path: Routes.recommendation,
      builder: (_, _) => const RecommendationScreen(),
    ),
    GoRoute(
      path: Routes.subscriptionPayment,
      builder: (_, s) =>
          SubscriptionPaymentScreen(draft: s.extra! as SubscriptionDraft),
    ),
    GoRoute(
      path: '/my-subscription/:id',
      builder: (_, s) => SubscriptionDetailScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/subscribe/:plan',
      builder: (_, s) => SubscribeScreen(planId: s.pathParameters['plan']!),
    ),
    GoRoute(path: Routes.favorites, builder: (_, _) => const FavoritesScreen()),
    GoRoute(path: Routes.support, builder: (_, _) => const SupportScreen()),
    GoRoute(
      path: Routes.notifications,
      builder: (_, _) => const NotificationsScreen(),
    ),
    GoRoute(path: Routes.search, builder: (_, _) => const SearchScreen()),
    GoRoute(path: Routes.tour, builder: (_, _) => const AppTourScreen()),
    GoRoute(path: Routes.guide, builder: (_, _) => const GuideScreen()),
    GoRoute(path: Routes.foodScan, builder: (_, _) => const FoodScanScreen()),
    GoRoute(path: Routes.run, builder: (_, _) => const RunScreen()),
    GoRoute(
      path: Routes.market,
      builder: (_, s) => MarketScreen(
        initialTab: s.uri.queryParameters['tab'] == 'store' ? 1 : 0,
      ),
      routes: [
        GoRoute(path: 'cart', builder: (_, _) => const CartScreen()),
        GoRoute(
          path: 'product/:id',
          builder: (_, s) => ProductScreen(id: s.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      path: Routes.bodybuilding,
      builder: (_, _) => const BodybuildingScreen(),
      routes: [
        GoRoute(
          path: 'session/:program/:day',
          builder: (_, s) => BbSessionScreen(
            programId: s.pathParameters['program']!,
            dayIndex: int.tryParse(s.pathParameters['day']!) ?? 0,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/news/:id',
      builder: (_, s) => NewsDetailScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/resource/:id',
      builder: (_, s) => ResourceDetailScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/player/:id',
      builder: (_, s) => WorkoutPlayerScreen(id: s.pathParameters['id']!),
    ),

    // 11. Bottom Navigation
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => HomeShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              builder: (_, _) => const MainScreen(),
              routes: [
                GoRoute(
                  path: 'workout',
                  builder: (_, _) => const WorkoutScreen(),
                  routes: [
                    GoRoute(
                      path: 'create',
                      builder: (_, _) => const CreateRoutineScreen(),
                    ),
                    GoRoute(
                      path: 'routine/:id',
                      builder: (_, s) =>
                          RoutineDetailScreen(id: s.pathParameters['id']!),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'progress',
                  builder: (_, _) => const ProgressScreen(),
                ),
                GoRoute(
                  path: 'nutrition',
                  builder: (_, _) => const NutritionScreen(),
                  routes: [
                    GoRoute(
                      path: 'meal/:id',
                      builder: (_, s) =>
                          MealDetailScreen(id: s.pathParameters['id']!),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'community',
                  builder: (_, _) => const CommunityScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: Routes.shop, builder: (_, _) => const ShopScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.subscription,
              builder: (_, _) => const SubscriptionScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.resources,
              builder: (_, _) => const NewsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.profile,
              builder: (_, _) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, _) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (_, _) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'devices',
                  builder: (_, _) => const DevicesScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

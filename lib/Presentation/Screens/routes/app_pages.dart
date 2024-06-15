import 'package:get/get.dart';

import '../splash/bindings/splash_binding.dart';
import '../splash/views/splash_view.dart';
import '../welcome/bindings/welcome_binding.dart';
import '../welcome/views/welcome_view.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.WELCOME,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
  ];
}

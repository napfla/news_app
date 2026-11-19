import 'package:get/get.dart';

import '../views/home_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(name: AppRoutes.home, page: () => const HomeView()),
  ];
}
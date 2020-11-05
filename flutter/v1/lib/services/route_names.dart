class RouteNames {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String passwordReset = '/passwordReset';
  static const String admin = '/admin';
  static const String adminCategory = '/adminCategory';
  static const String adminPushNotification = '/adminPushNotification';
  static const String forum = '/forum';
  static const String forumEdit = '/forumEdit';
  static const String forumView = '/forumView';
  static const String mobileAuth = '/mobileAuth';
  static const String mobileCodeVerification = '/mobileCodeVerification';
  static const String search = '/search';
}

List<String> preventRouteDuplication = [
  RouteNames.login,
  RouteNames.register,
  RouteNames.profile,
  RouteNames.settings,
  RouteNames.passwordReset,
  RouteNames.admin,
  RouteNames.adminCategory,
  RouteNames.adminPushNotification,
  RouteNames.forum,
  RouteNames.forumEdit,
  RouteNames.forumView,
  RouteNames.mobileAuth,
  RouteNames.mobileCodeVerification,
  RouteNames.search,
];

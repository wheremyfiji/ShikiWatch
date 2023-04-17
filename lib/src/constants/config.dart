class AppConfig {
  AppConfig._();

  static const int databaseVersion = 1;
  static const String databaseVersionKey = "isarVersionKey";

  /// keys
  static const Duration maxCacheAge = Duration(minutes: 5); //30

  static const String dioCacheForceRefreshKey = 'dio_cache_force_refresh_key';
  static const String dioNeedToCacheKey = 'dio_need_to_cache_key';
  // Theme key to store and retrieve user preferred theme
  static const String themeModeKey = "theme";
  // Appcolor key to store and retrieve user preferred appcolor
  static const String appColorKey = "appColor";

  /// API url
  static const String baseUrl = 'https://shikimori.me/api/';
  static const String staticUrl = 'https://shikimori.me';
  //final kStaticUrl = Uri.parse('https://shikimori.one');

  // static const String trendingUrl = "trending";
  // static const String popularUrl = "popular";
  // static const String searchUrl = "advanced-search";
  // static const String infoUrl = "info";
  // static const String watchUrl = "watch";
}
